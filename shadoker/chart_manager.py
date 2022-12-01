#from __future__ import annotations
# External package imports
import copy
import glob
import json
#import orjson
import logging
import os
import platform
import re
import shutil
import subprocess
import traceback
import urllib.request
from datetime import datetime, timezone
from git import Repo
from pathlib import Path, PurePosixPath
from typing import Tuple, Dict, List, TypeVar, Type
from urllib.parse import urlparse


# Local shadoker imports
# Python import madness below (for test/)
if (__name__.startswith('shadoker')):
    from .archiver import extract
    from .change_set import ChangeSet
    from .item_status import Status
    from .object_matcher import ObjectMatcher
    from .shadoker_globals import getBoolProperty, filterDict, randomindex, checkFileHash, checkUri, forcedrmdir, sanitizeDirectoryName, sanitizeEnvironmentVariable, sanitizeTagToken, fromDockerDatetime, camelToKebabCase, getFirstMatch, getArrayProperty
    from .shadoker_globals import PACKAGE_INSTALLDIR, IMAGEINFO_DIR, TYPE_ARTIFACT, TYPE_IMAGE, PATTERN_MANIFEST, NOW, TIMESTAMP_NOW, TIMESTAMP_STR_NOW, DEPENDENCY_PROPERTY_KEY, RESERVED_IMAGE_PROPERTIES
    from .template_renderer import TemplateRenderer
    from . import build_result
    from . import package_manager
else:
    from archiver import extract
    from change_set import ChangeSet
    from item_status import Status
    from object_matcher import ObjectMatcher
    from shadoker_globals import getBoolProperty, filterDict, randomindex, checkFileHash, checkUri, forcedrmdir, sanitizeDirectoryName, sanitizeEnvironmentVariable, sanitizeTagToken, fromDockerDatetime, camelToKebabCase, getFirstMatch, getArrayProperty
    from shadoker_globals import PACKAGE_INSTALLDIR, IMAGEINFO_DIR, TYPE_ARTIFACT, TYPE_IMAGE, PATTERN_MANIFEST, NOW, TIMESTAMP_NOW, TIMESTAMP_STR_NOW, DEPENDENCY_PROPERTY_KEY, RESERVED_IMAGE_PROPERTIES
    from template_renderer import TemplateRenderer
    import build_result
    import package_manager

logger = logging.getLogger()

CHART_DATA_DIR = 'chartData'

class ChartManager:
    def __init__(self, directory, package_manager: Type[package_manager.PackageManager], image_manager: Type[package_manager.ImageManager]):
        self.__charts = set()
        self.__error_charts = dict()
        self.__package_manager = package_manager
        self.__image_manager = image_manager
        self.__directory = directory.resolve()
        logger.debug(f'Reading "charts" directory "{directory}"')
        for sub_directory, dirs, files in os.walk(directory):
            logger.debug('Reading sub-directory "%s" (with parent %s) which has %s dirs and %s files' % (sub_directory, Path(sub_directory).parent, dirs, files))
            if (Path(sub_directory).name == CHART_DATA_DIR):
                for filename in files:
                    if (filename.endswith('.json')):
                        try:
                            f = Path(sub_directory, filename)
                            self.__addChart(f)
                        except Exception as e:
                            self.__error_charts[f] = f'{e}'
                            logger.debug(f'File "{f}" is not a valid Chart: {e}')

    @property
    def repo(self):
        return self.__package_manager.repo

    @property
    def size(self) -> int:
        """Total count of charts"""
        return len(self.__charts)

    def __addChart(self, file):
        chart = Chart(file, self.__package_manager, self.__image_manager)
        #if chart.name in self.__images_by_names:
        #    raise KeyError('Image with name "%s" is already defined. This definition is skipped.' % img.name)
        self.__charts.add(chart)
        logger.debug(f"Adding : {chart}")
        return chart

    def listCharts(self, change_set: ChangeSet = None, touched: bool = False):
        if change_set or touched:
            checked_folders = dict()
            return frozenset(c for c in self.__charts if c.belongsTo(change_set, touched, checked_folders))
        else:
            return copy.copy(self.__charts)

    def findChart(self, predicate):
        if (not callable(predicate)):
            raise Exception('Predicate must be callable')
        return next((i for i in self.__charts if predicate(i)), None)

    def findCharts(self, predicate):
        if (not callable(predicate)):
            raise Exception('Predicate must be callable')
        return list(i for i in self.__charts if predicate(i))

    def errors(self):
        """Returns all the error found in chart JSON files"""
        return copy.copy(self.__error_charts)


class Chart:
    def __get_property(self, data, prop_name: str, mandatory: bool, default_value = None):
        if prop_name in data:
            return data[prop_name]
        else:
            if mandatory:
                raise ChartDefinitionError(self, f'Missing mandatory "{prop_name}" property in "chartData"')
            return default_value
        
    def __init__(self, config_file, package_manager: package_manager.PackageManager, image_manager: package_manager.ImageManager):
        self._name = None
        self.__config_file = config_file
        self.__config_file_abs = os.path.abspath(config_file)
        self.__config_file_posix = str(PurePosixPath(config_file))
        self.__config_file_git = package_manager.getGitRelativePath(self.__config_file_posix)
        self._revision = package_manager.revision
        if (self.__config_file_posix in package_manager.untracked_files):
            self.__status = Status.UNTRACKED
            self._revision = None
        else:
            self.__status = Status.STAGED if package_manager.isStaged(self.__config_file_git) else Status.OK
        with open(config_file) as f:
            data = json.load(f)
        self.__data = data
        if 'chartData' not in data:
            raise ChartDefinitionError(self, 'Wrong JSON format, missing "chartData" top-level property')
        self.__chart_folder = PurePosixPath(config_file).parents[1]
        self.__chart_folder_git = package_manager.getGitRelativePath(self.__chart_folder) + '/'
        self.__chart_full_folder = Path(config_file).parents[1].absolute()
        self.__chart_dist_folder = Path(self.__chart_full_folder, '_dist')
        self.__chart_build_folder = Path(self.__chart_full_folder, '_build')
        self.__chart_details = data['chartData']
        
        self._name = self.__get_property(self.__chart_details, 'name', True)
        self._product = self.__get_property(self.__chart_details, 'product', True)
        self._version = self.__get_property(self.__chart_details, 'version', True)
        self._appVersion = self.__get_property(self.__chart_details, 'appVersion', True)
        self._chart_file = self.__get_property(self.__chart_details, 'chartFile', False, 'Chart.yaml')
        self._chart_value_files = self.__get_property(self.__chart_details, 'helmValueFiles', False, [])
        if isinstance(self._chart_value_files, str):
            self._chart_value_files = [self._chart_value_files]
        self._helm_chart_dir = self.__get_property(self.__chart_details, 'helmChartDir', False, 'helm')
        self.__helm_full_folder = Path(self.__chart_folder,self._helm_chart_dir).absolute()

        self._dependencies = set()
        self._dependencies_by_names = dict()
        all_dependencies = []
        all_image_dependencies = []
        all_artifact_dependencies = []
        root_properties = filterDict(lambda k, v: k not in RESERVED_IMAGE_PROPERTIES, self.__chart_details)
        root_properties['name'] = self._name
        root_properties['buildTimestamp'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        logger.debug(f'Adding chart properties {root_properties}')
        self._renderer = TemplateRenderer(parent=package_manager.templateRenderer)
        self._renderer.addProperties(root_properties)
        if 'dependencies' in self.__chart_details:
            logger.debug('Resolving dependencies for %s' % self._name)
            for dep in self.__chart_details['dependencies']:
                dependency_name = dep['name']
                dependency_ref = dep['reference']
                dependency_ref_fallback = dep['referenceFallback'] if 'referenceFallback' in dep else None
                dependency_type = dep['type']
                if not dependency_ref:
                    raise ChartDefinitionError(self, f'Missing "reference" for dependency in {self}')
                if not dependency_name:
                    raise ChartDefinitionError(self, f'Missing "name" for dependency <{dependency_ref}> in {self}')
                elif dependency_name in self._dependencies_by_names:
                    raise ChartDefinitionError(self, f'Already declared "{dependency_name}" dependency <{dependency_ref}> in {self}')
                logger.debug('.. resolving %s=%s' % (dependency_name, dependency_ref))
                p = package_manager.getPackage(dependency_ref)
                if p is None:
                    if not dependency_ref_fallback is None:
                        p = package_manager.getPackage(dependency_ref_fallback)
                        if p is None:
                            raise ChartDefinitionError(self, f'Dependency not found <{dependency_ref}> or <{dependency_ref_fallback}> in Image[{self._name}]')
                    else:
                        raise ChartDefinitionError(self, f'Dependency not found <{dependency_ref}> in Image[{self._name}]')
                if p.type != dependency_type:
                    raise ChartDefinitionError(self, f'Wrong dependency "{dependency_name}" has type <{p.type}> but expected [{dependency_type}] in Image[{self._name}]')
                logger.debug(f'... found {p.name}')
                img = None
                dependency_props = p.injectIntoRenderer(self._renderer, dependency_name)
                all_dependencies.append(dependency_props)
                if p.type == TYPE_IMAGE:
                    img = image_manager.getImage(dependency_ref)
                    if img is None:
                        raise ChartDefinitionError(self, f'Image dependency "{dependency_ref}" is not defined in shadoker')
                    self._renderer.addProperties({DEPENDENCY_PROPERTY_KEY: {dependency_name: {'imageShortName': img.short_name }}})
                    all_image_dependencies.append(dependency_props)
                else:
                    all_artifact_dependencies.append(dependency_props)
                self._dependencies.add(p)
                self._dependencies_by_names[dependency_name] = {'ref': p, 'type': dependency_type, 'image': img}
        self._renderer.addProperty('all_dependencies', all_dependencies)
        self._renderer.addProperty('has_dependencies', not not all_dependencies)
        self._renderer.addProperty('all_image_dependencies', all_image_dependencies)
        self._renderer.addProperty('has_image_dependencies', not not all_image_dependencies)
        self._renderer.addProperty('all_artifact_dependencies', all_artifact_dependencies)
        self._renderer.addProperty('has_artifact_dependencies', not not all_artifact_dependencies)

    @property
    def name(self) -> str:
        return str(self._name)

    @property
    def version(self) -> str:
        return str(self._version)

    @property
    def product(self) -> str:
        return str(self._product)

    @property
    def input_chart_file(self) -> str:
        return str(Path(CHART_DATA_DIR,self._chart_file))

    @property
    def product_version(self) -> str:
        return str(self._appVersion)
    
    @property
    def helm_directory(self) -> str:
        return str(self.__helm_full_folder)

    @property
    def helm_relative_directory(self) -> str:
        return self.__helm_folder

    def belongsTo(self, change_set: ChangeSet, touched: bool, check_folder: dict):
        """Is this Chart part of a given ChangeSet ?
           Method checks Chart definition and associated folder."""
        if change_set:
            if change_set.isChangedFile(self.__config_file):
                return True
            if touched and change_set.isTouchedFile(self.__config_file):
                return True
            if self.__chart_folder in check_folder:
                if check_folder[self.__chart_folder]:
                    return True
            else:
                if change_set.isChangedFolder(self.__chart_folder):
                    check_folder[self.__chart_folder] = True
                    return True
                if touched and change_set.isTouchedFolder(self.__chart_folder):
                    check_folder[self.__chart_folder] = True
                    return True
                check_folder[self.__chart_folder] = False
            return False
        return True

    def build(self, extra_tags: List[str] = [], dry_run: bool = False) -> build_result.BuildResult:
        """Builds this Image."""
        #from build_result import BuildResult
        result = build_result.BuildResult(self)
        result.logMessage(f'Building {self.name}')

        do_build = True
        build_env = dict(os.environ)
        os.chdir(self.__chart_full_folder)
        # Create folders for final distribution package
        if self.__chart_dist_folder.exists():
            forcedrmdir(self.__chart_dist_folder)
        os.makedirs(self.__chart_dist_folder, 0o777, True)
        result.dist_directory = str(self.__chart_dist_folder)
        images_dir = Path(self.__chart_dist_folder, 'images')
        os.makedirs(images_dir, 0o777, True)
        packages_dir = Path(self.__chart_dist_folder, 'packages')
        os.makedirs(packages_dir, 0o777, True)

        # Create folder for Helm chart build, with templated Chart.yaml
        if self.__chart_build_folder.exists():
            forcedrmdir(self.__chart_build_folder)
        result.build_directory = str(self.__chart_dist_folder)
        shutil.copytree(self.helm_directory, self.__chart_build_folder)
        # Generate templated Chart.yaml
        self._renderer.renderFile(self.input_chart_file, str(Path(self.__chart_build_folder, 'Chart.yaml')))
        # Build Helm package
        helm_commands = ['helm', 'package', str(self.__chart_build_folder), '-d', str(self.__chart_dist_folder)]
        result.logMessage(f' Executing {helm_commands}')
        helm_process = subprocess.run(helm_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
        if helm_process.returncode != 0:
            result.logError(f' {helm_process.stdout}', helm_process.returncode)
        else:
            result.logMessage(f' {helm_process.stdout}')

        # Generate templated value files
        for value_file in self._chart_value_files:
            try:
                result.logMessage(f' Processing value file {value_file}')
                self._renderer.renderFileLoose(value_file, str(Path(self.__chart_dist_folder, value_file)))
            except Exception as e:
                result.logError(f' Cannot process value file {value_file} : {e}')

        # Get a copy of all required dependencies, Docker images and other packages
        image_import_shell = Path(images_dir, f'import-images.sh')
        image_import_bat = Path(images_dir, f'import-images.bat')
        with open(image_import_shell, mode='w+', newline='\n') as import_shell_file, open(image_import_bat, mode='w+', newline='\r\n') as import_bat_file:
            # Linux script
            import_shell_file.write('#!/usr/bin/env bash\n\n')
            import_shell_file.write('REGISTRY=$1\n')
            import_shell_file.write('if [ -z "$REGISTRY" ]\n')
            import_shell_file.write('then\n')
            import_shell_file.write('  echo Missing first parameter which must set the target REGISTRY where to import images\n')
            import_shell_file.write('  exit 1\n')
            import_shell_file.write('fi\n')
            import_shell_file.write('\nSCRIPT=$(readlink -f "$0")\n')
            import_shell_file.write('BASEDIR=$(dirname "$SCRIPT")\n')
            # Windows script
            import_bat_file.write('IF "%~1"=="" ECHO "Missing first parameter which must set the target REGISTRY where to import images" & EXIT /B 1\n')
            import_bat_file.write('SET REGISTRY=%~1\n')
            import_bat_file.write('SET BASEDIR=%~dp0\n')
            for dep_name in self._dependencies_by_names:
                dep = self._dependencies_by_names[dep_name]['ref']
                result.logMessage(f'Resolving dependency "{dep_name}" --> {dep}')
                if dep.type == TYPE_IMAGE:
                    exported = False
                    image = self._dependencies_by_names[dep_name]['image']
                    image_file_name = sanitizeDirectoryName(image.short_name)
                    (ok, image_data) = image.inspect(None, True)
                    result.logMessage(f' Saving image metadata file {image_file_name}.json')
                    image_data_file = Path(images_dir, f'{image_file_name}.json')
                    image_extension = 'tar' if (platform.system() == 'Windows') else 'tar'
                    image_save_file = Path(images_dir, f'{image_file_name}.{image_extension}')
                    with open(image_data_file, mode='w+') as data_file:
                        json.dump(image_data, data_file, indent=2, ensure_ascii=False)
                    tag_commands = ['docker', 'tag', image.name, image.short_name]
                    result.logMessage(f' Executing {tag_commands}')
                    tag_process = subprocess.run(tag_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
                    if tag_process.returncode != 0:
                        result.logError(f' {tag_process.stdout}', tag_process.returncode)
                    else:
                        result.logMessage(f' {tag_process.stdout}')
                        save_commands = ['docker', 'save', image.short_name, '-o', str(image_save_file)]
                        gzip_commands = []
                        if platform.system() == 'Windows':
                            pass
                        else:
                            gzip_commands += ['gzip', str(image_save_file)]
                        result.logMessage(f' Executing {save_commands}')
                        save_process = subprocess.run(save_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
                        if save_process.returncode != 0:
                            result.logError(f' {save_process.stdout}', save_process.returncode)
                        else:
                            result.logMessage(f' {save_process.stdout}')
                            if gzip_commands:
                                result.logMessage(f' Executing {gzip_commands}')
                                gzip_process = subprocess.run(gzip_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
                                if gzip_process.returncode != 0:
                                    result.logError(f' {gzip_process.stdout}', gzip_process.returncode)
                                else:
                                    result.logMessage(f' {gzip_process.stdout}')
                                    exported = True
                                    image_save_file = image_save_file.name
                                    image_save_file += '.gz'
                            else:
                                image_save_file = image_save_file.name
                                exported = True
                    if exported:
                        # Linux script
                        import_shell_file.write(f'\necho "importing [{image.short_name}]"\n')
                        import_shell_file.write(f'docker load -i "${{BASEDIR}}/{image_save_file}"\n')
                        import_shell_file.write(f'docker tag "{image.short_name}" "${{REGISTRY}}/{image.short_name}"\n')
                        import_shell_file.write(f'docker push "${{REGISTRY}}/{image.short_name}"\n')
                        # Windows script
                        import_bat_file.write(f'\nECHO "importing [{image.short_name}]"\n')
                        import_bat_file.write(f'docker load -i "%BASEDIR%\{image_save_file}"\n')
                        import_bat_file.write(f'docker tag "{image.short_name}" "%REGISTRY%/{image.short_name}"\n')
                        import_bat_file.write(f'docker push "%REGISTRY%/{image.short_name}"\n')
                    else:
                        import_shell_file.write(f'\necho "error, cannot import [{image.short_name}] which has not been archived correctly"\n')
                        import_bat_file.write(f'\ECHO "error, cannot import [{image.short_name}] which has not been archived correctly"\n')
                elif dep.type == TYPE_ARTIFACT:
                    pkg =self._dependencies_by_names[dep_name]['ref']
                    result.logMessage(f' Getting package for artifact {pkg.name}')
                    pkg.download(packages_dir, False)

        result.end()
        return result

    def __str__(self):
        return f'Chart[{self.name}]'

class ChartDefinitionError(os.error):
    """Exception raised for errors in the Chart instanciation.

    Attributes:
        chart -- Chart in which the error occurred
        message -- explanation of the error
    """

    def __init__(self, chart, message):
        self.chart = chart
        self.message = message

    @property
    def chartName(self):
        return self.chart.name if self.chart else None

    @property
    def chartFile(self):
        return self.chart.file if self.chart else None

    def __str__(self):
        return f'ChartDefinitionError: {self.message}'