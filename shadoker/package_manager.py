# External package imports
import copy
import glob
#import json
import orjson
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
from typing import Tuple, Dict, List, Union, Any
from urllib.parse import urlparse

from shadoker import GRYPE_PATH, SYFT_PATH
from shadoker.archiver import extract
from shadoker.change_set import ChangeSet
from shadoker.item_status import Status
from shadoker.object_matcher import ObjectMatcher
from shadoker.shadoker_globals import getBoolProperty, filterDict, randomindex, checkFileHash, checkUri, forcedrmdir, sanitizeDirectoryName, sanitizeEnvironmentVariable, sanitizeTagToken, fromDockerDatetime, camelToKebabCase, getFirstMatch, getArrayProperty, deepupdate, sha256toUUIDurn, getValue
from shadoker.shadoker_globals import PACKAGE_INSTALLDIR, IMAGEINFO_DIR, TYPE_ARTIFACT, TYPE_IMAGE, PATTERN_MANIFEST, NOW, TIMESTAMP_NOW, TIMESTAMP_STR_NOW, DEPENDENCY_PROPERTY_KEY, RESERVED_IMAGE_PROPERTIES
from shadoker.template_renderer import TemplateRenderer
import shadoker.build_result as build_result
from shadoker.test_result import TestResult, TestStatus

logger = logging.getLogger()


# TODO [1]: Manage a tree of properties to be used in package definition files ?
# PROPERTY_TREE = dict()

SHADOKER_VAR_PREFIX = 'SHDKR_'
DEFAULT_TIMEOUT_SECONDS = 60  # Applies to hooks and tests
EXPANDED_PACKAGE_FILES = []


class PackageManager:
    def __init__(self, repo: Repo, directory: Path, template_renderer: TemplateRenderer, configuration: dict):
        self.__repo = repo
        self.__configuration = copy.copy(configuration)
        self.__registry_name = False
        if isinstance(configuration, dict) and 'DOCKER_REGISTRY' in configuration:
            self.__registry_name = configuration['DOCKER_REGISTRY']
        if repo:
            try:
                self.__user = repo.git.config('user.name')
            except Exception:
                self.__user = ''
            self.__repo_root = repo.git.rev_parse('--show-toplevel')
            self.__repo_head_commit = repo.head.commit
            self.__untracked_files = repo.untracked_files
            self.__staged_files = [d.a_path for d in repo.index.diff('HEAD')]
        else:
            self.__user = ''
            self.__repo_root = str(Path(os.path.dirname(__file__), '..').resolve())
            self.__repo_head_commit = 'HEAD'
            self.__untracked_files = []
            self.__staged_files = []
        self.__directory = directory.resolve()
        self.__package_install_dir = Path(self.__directory, PACKAGE_INSTALLDIR)  # Absolute path to Packages installation directory
        self._template_renderer = template_renderer
        # PROPERTY_TREE[directory] = TemplateRenderer(Path(directory, 'shadofig.json'), template_renderer)
        self.__packages = set()
        self.__packages_by_names = dict()
        self.__error_packages = dict()
        logger.debug('Reading "packages" directory "%s"' % directory)

        for sub_directory, dirs, files in os.walk(directory):
            logger.debug('Reading sub-directory "%s" (with parent %s) which has %s dirs and %s files' % (sub_directory, Path(sub_directory).parent, dirs, files))
            # TODO [1]: Manage a tree of properties to be used in package definition files ?
            # subdir_properties = TemplateRenderer(str(Path(sub_directory, 'shadofig.json')), PROPERTY_TREE[str(Path(sub_directory).parent)])
            # PROPERTY_TREE[sub_directory] = subdir_properties
            for filename in files:
                if (filename.endswith('.json')):
                    try:
                        f = Path(sub_directory, filename)
                        self.__addPackage(f, template_renderer)
                    except Exception as e:
                        self.__error_packages[f] = str(e)
                        logger.debug('File is %s is not a valid Package' % f, e)
        for p in self.__packages:
            p.resolveDependencies(self)

    @property
    def repo(self):
        return self.__repo

    @property
    def configuration(self):
        return self.__configuration

    def getConfigurationValue(self, key: str) -> Any:
        """ Returns a configuration value for this PackageManager.
            key: configuration key to find
            returns: the corresponding configuration value or None
        """
        if isinstance(self.__configuration, dict) and key in self.__configuration:
            return self.__configuration[key]
        return None

    @property
    def registry_name(self) -> Union[str, bool]:
        return self.__registry_name

    @property
    def untracked_files(self):
        return self.__untracked_files

    @property
    def revision(self) -> str:
        return self.__repo_head_commit

    @property
    def user(self) -> str:
        return self.__user

    @property
    def directory(self) -> Path:
        return self.__directory

    @property
    def packagesInstallationDirectory(self) -> Path:
        return self.__package_install_dir

    @property
    def templateRenderer(self):
        return self._template_renderer

    @property
    def size(self) -> int:
        """Total count of packages"""
        return len(self.__packages)

    def getGitRelativePath(self, path):
        if (not isinstance(path, str)):
            path = str(path)
        if (path.startswith(self.__repo_root)):
            path = path[len(self.__repo_root):]
            if (path[0] == os.path.sep):
                path = path[1:]
        return path

    def errors(self):
        """Returns all the errors found in package JSON files"""
        return copy.copy(self.__error_packages)

    def __addPackage(self, file, properties: TemplateRenderer):
        p = Package(self, file, properties)
        if (p.name in self.__packages_by_names):
            raise KeyError('Package with name "%s" is already defined. This definition is skipped.' % p.name)
        self.__packages.add(p)
        self.__packages_by_names[p.name] = p
        logger.debug("Adding : %s" % p)

    def getPackage(self, package_name):
        return self.__packages_by_names[package_name] if (package_name in self.__packages_by_names) else None

    def findPackage(self, predicate):
        if (not callable(predicate)):
            raise Exception('Predicate must be callable')
        return next((p for p in self.__packages if predicate(p)), None)

    def listPackages(self, change_set=None, touched: bool = False, staged: bool = False):
        if (change_set or touched):
            return frozenset(filter(lambda p: p.belongsTo(change_set, touched, staged), self.__packages))
        else:
            return copy.copy(self.__packages)

    def isStaged(self, file):
        return file in self.__staged_files

    def listPackagesClassification(self, result: dict = None) -> dict:
        if (not isinstance(result, dict)):
            result = dict()
        for p in self.__packages:
            product = p.product
            if isinstance(product, str):
                product = product.lower()
            if (product in result):
                row = result[product]
            else:
                row = dict()
                result[product] = row
            asset = p.asset
            if isinstance(asset, str):
                asset = asset.lower()
            if (asset in row):
                row[asset].append(p)
            else:
                row[asset] = [p]
        return result

    def updateOrCreatePackage(self, type: str, name: str, data: dict, create: bool) -> bool:
        if not type:
            if len(data) == 1:
                type = next(iter(data))
                if not type in [TYPE_ARTIFACT, TYPE_IMAGE]:
                    print(f'Type "{type}" declared in update data does not exist')
                    return False
                data = data[type]
            else:
                print(f'Cannot infer type from update data')
                return False
        elif len(data) == 1:
            infer_type = next(iter(data))
            if infer_type == type:
                data = data[type]
            else:
                print(f'Update data infered type "{infer_type}" differs from given type "{type}"')
                return False
        if not name:
            if 'name' in data:
                name = data['name']
            else:
                print(f'Cannot infer name from update data')
                return False
        pkg = self.getPackage(name)
        if pkg is None:
            if create:
                print(f'Creating package "{type}" named "{name}"')
                return self.createPackage(type, name, data)
            else:
                print(f'Package {name} not found, and not created')
                return False
        else:
            if pkg.type != type:
                print(f'Found package {name} to update, but with type {pkg.type} instead of {type}')
                return False
            else:
                print(f'Updating package "{type}" named "{name}"')
                return pkg.updateWith(data)

    def createPackage(self, type: str, name: str, data: dict) -> bool:
        product = data['product'].lower() if 'product' in data else 'fircosoft'
        asset = data['asset'].lower() if 'asset' in data else 'misc'
        if 'name' in data:
            if data['name'] != name:
                raise Exception(f'Cannot create Package "{name}", mismatch with provided data property "{data["name"]}"')
        else:
            data['name'] = name
        folder = self.directory / f'{type}s' / product / asset
        os.makedirs(name=folder, exist_ok=True)
        print(f'creating folder for {type} reference "{folder} in {os.getcwd()}')
        config_file = folder / (name.replace('/', '_').replace(':', '@') + '.json')
        print(f'creating {type} reference {config_file}')
        with open(config_file, 'wb+') as f:
            new_package = dict()
            new_package[type] = data
            f.write(orjson.dumps(new_package, option=orjson.OPT_INDENT_2))
            # json.dump(new_package, f, indent=2, ensure_ascii=False)
        self.repo.index.add([self.getGitRelativePath(config_file)])
        return True


class Package:
    def __init__(self, package_manager, config_file, parent_renderer: TemplateRenderer = None):
        self.__package_manager = package_manager
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
        if parent_renderer:
            data = parent_renderer.renderJsonFile(config_file)
        else:
            with open(config_file) as f:
                data = orjson.loads(f.read())
        self.__parent_renderer = parent_renderer
        self._type = None
        if TYPE_ARTIFACT in data:
            self._type = TYPE_ARTIFACT
        elif TYPE_IMAGE in data:
            self._type = TYPE_IMAGE
        if not self._type:
            raise Exception(f'Wrong JSON format, missing "{TYPE_ARTIFACT}" or "{TYPE_IMAGE}" top-level property')
        self.__package_details = data[self._type]
        self._name = self.__package_details['name']
        if self._type == TYPE_IMAGE:
            if 'short_name' in self.__package_details:
                raise Exception(f'"short_name" is a reserved property')
            if  package_manager.registry_name:
                self._short_name = re.sub(rf'^{package_manager.registry_name}/', '', self._name)
            else:
                self._short_name = self._name
            self.__package_details['short_name'] = self._short_name
        if self._type == TYPE_ARTIFACT and (self._name.find(':') >= 0 or self._name.find('/') >= 0 or self._name.find('\\') >= 0):
            raise Exception(f'Wrong artifact name "{self._name}", cannot contain ":", "/" or "\\"')
        self._dependencies = set()

    @property
    def type(self) -> str:
        return self._type

    @property
    def name(self) -> str:
        return self._name

    @property
    def mutable(self) -> bool:
        return getBoolProperty(self.__package_details, 'mutable', True)

    @property
    def uri(self) -> str:
        return self.__package_details['uri'] if 'uri' in self.__package_details else None

    @property
    def hash(self) -> str:
        if ('hash' in self.__package_details):
            return self.__package_details['hash']
        elif ('digest' in self.__package_details):
            return self.__package_details['digest']
        else:
            return None

    @property
    def buildDate(self) -> str:
        return self.__package_details['buildDate'] if 'buildDate' in self.__package_details else None

    @property
    def product(self) -> str:
        return self.__package_details['product'] if 'product' in self.__package_details else None

    @property
    def asset(self) -> str:
        return self.__package_details['asset'] if 'asset' in self.__package_details else None

    @property
    def component(self) -> str:
        return self.__package_details['component'] if 'component' in self.__package_details else None

    @property
    def version(self) -> str:
        return self.__package_details['version'] if 'version' in self.__package_details else None

    @property
    def env(self) -> str:
        if 'env' in self.__package_details:
            return self.__package_details['env']
        elif 'environment' in self.__package_details:
            return self.__package_details['environment']
        elif 'repository' in self.__package_details \
          and 'branch' in self.__package_details['repository'] \
          and 'release' in self.__package_details['repository']['branch'].lower():
            return 'release'
        else:
            return None

    @property
    def gitPath(self):
        return self.__config_file_git

    @property
    def config_file(self):
        return self.__config_file

    @property
    def config_file_abs(self):
        return self.__config_file_abs

    def getProperty(self, prop: str, default=None):
        return self.__package_details[prop] if (prop in self.__package_details) else default

    def getFirstProperty(self, prop1: str, prop2: str = None, prop3: str = None, prop4: str = None, default=None):
        return getFirstMatch(self.__package_details, prop1, prop2, prop3, prop4, default)

    def gitInfo(self):
        """Retrieves the git information for this Package.
           Returns: a tuple with revision, author and timestamp or None"""
        git_info = self.__package_manager.repo.git.log('-n 1', '--pretty=format:''%H|%an|%ct''', '--', self.config_file).split('|')
        if (len(git_info) == 3):
            revision, author, timestamp = git_info
            timestamp = datetime.fromtimestamp(int(timestamp)).strftime('%Y%m%dT%H%M%SZ')
            return revision, author, timestamp
        else:
            return None

    def belongsTo(self, change_set: ChangeSet, touched: bool, staged: bool):
        """Is this package is part of a given ChangeSet ? This method checks package definition file status."""
        if (staged and self.__status == Status.STAGED):
            return True
        if (change_set):
            if (change_set.isChangedFile(self.__config_file)):
                return True
            if (touched and (self.__status == Status.UNTRACKED or change_set.isTouchedFile(self.__config_file))):
                return True
            return False
        return True

    def match(self, matcher: ObjectMatcher):
        if matcher:
            return matcher.match(self.__package_details)
        return False

    def updateWith(self, updater: ObjectMatcher) -> bool:
        if not self.mutable:
            raise Exception(f'Cannot update immutable package {self}')
        if not isinstance(updater, ObjectMatcher):
            if (isinstance(updater, dict)):
                updater = ObjectMatcher(updater)
            else:
                raise Exception(f'Cannot update package {self}, wrong argument type')
        if updater:
            uri = updater.getCriteria('uri')
            if uri:
                hash = updater.getCriteria('hash')
                uri_ok, uri_log = checkUri(uri, hash)
                if not uri_ok:
                    raise Exception(f'Cannot update package {self} with new provided uri: {uri_log}')
            old_data = copy.deepcopy(self.__package_details)
            old_data.pop('short_name', None)
            new_data, changes = updater.update(old_data)
            # Special case of uri specified without hash, remove former hash value if existing
            if uri and 'hash' in new_data and not hash and uri != self.uri:
                del new_data['hash']
            if changes == 0:
                return False
            else:
                self.__package_details = new_data
                logger.debug(f'Updating package {self} with {new_data}')
                with open(self.__config_file_abs, 'wb+') as f:
                    new_package = dict()
                    new_package[self._type] = self.__package_details
                    f.write(orjson.dumps(new_package, option=orjson.OPT_INDENT_2))
                    # json.dump(new_package, f, indent=2, ensure_ascii=False)
                self.__package_manager.repo.index.add([self.__config_file_git])
            return True
        return False

    def __str__(self):
        return f'Package-{self._type}[{self._name}]'

    def properties(self) -> dict:
        """ Properties related to this Package
        Returns
        -------
        dict
            A dictionary with these Package properties:
            * all mandatory properties such as 'name', 'version', ...
            * any additional property provided in the JSON file
            * 'filename' : the name of the downloaded file for an artifact Package, derived from the 'uri' property
        """
        props = copy.deepcopy(self.__package_details)
        branch = ''
        if 'branch' in self.__package_details:
            branch = self.__package_details['branch']
        elif 'repository' in self.__package_details and 'branch' in self.__package_details['repository']:
            branch = self.__package_details['repository']['branch']
        if branch:
            branch = sanitizeTagToken(branch)
        props['branchTag'] = branch
        deepupdate(props, {'repository': { 'branchTag': branch}})
        if self.type == TYPE_ARTIFACT:
            urlTokens = urlparse(self.uri)
            package_file = os.path.basename(urlTokens.path)
            props['filename'] = str(package_file)
        return props

    def injectIntoRenderer(self, renderer: TemplateRenderer, variable_name: str) -> dict:
        if not renderer:
            renderer = TemplateRenderer(None, self.__parent_renderer)
        props = self.properties()
        #print(f'injecting <{variable_name}> : {props}')
        renderer.addProperties({DEPENDENCY_PROPERTY_KEY: {variable_name: props}})
        return props

    def resolveDependencies(self, package_manager: PackageManager):
        if ('dependencies' in self.__package_details):
            logger.debug('Resolving dependencies for %s' % self._name)
            for (depName, depVersion) in self.__package_details['dependencies']:
                p = package_manager.getPackage(depName)
                if (p is None):
                    raise Exception('Missing dependency %s in package %s' % depName, self._name)
                self._dependencies.add(p)

    def inspect(self) -> Tuple[bool, str]:
        """ Checks this Package's uri is valid (HTTP 200), and if specified hash matches
        """
        if (self.type == TYPE_ARTIFACT):
            uri = self.uri
            if (uri is None):
                return (False, 'NO URI')
            return checkUri(uri, self.hash)
        else:
            return (True, 'SKIP IMAGE REFERENCE')

    def download(self, dir, expand: bool) -> dict:
        """ Downloads this Package to a local destination and optionally uncompress it.

        Parameters
        ----------
        dir : _PathLike
            Directory - relative to the Image under build - where to download this Package
        expand : bool
            Also uncompress the downloaded archive file

        Raises
        ------
        Error
            If download or uncompress operations went wrong

        Returns
        -------
        dict
            A dictionary with the locations of the downloaded and uncompressed Package:
            * 'path' : relative path of the downloaded file
            * 'filename' : the name of the downloaded file
            * 'installpath' : relative path of the uncompressed folder
            * 'dirname' : the name of the uncompressed folder (or filename without .tar/.zip/.gz extension)
        """
        # Create Package directory, download if necessary
        package_file_installation_dir = Path(self.__package_manager.packagesInstallationDirectory, self._name)
        os.makedirs(package_file_installation_dir, 0o777, True)
        urlTokens = urlparse(self.uri)
        package_file = os.path.basename(urlTokens.path)
        package_file_installation_path = Path(package_file_installation_dir, package_file)
        if (checkFileHash(package_file_installation_path, self.hash) != 0):
            logger.debug(f' -- downloading {self.uri} to {package_file_installation_path}')
            urllib.request.urlretrieve(self.uri, package_file_installation_path)
            if (self.hash and checkFileHash(package_file_installation_path, self.hash) != 0):
                raise Exception(f'Downloaded file {self.uri} does not match specified hash {self.hash}')
        else:
            logger.debug(f' -- keeping file {package_file_installation_path} with hash {self.hash}')

        # Copy Package file to the given Image directory
        package_dest_dir = Path(dir, self._name)
        logger.debug(f' -- copying {package_file_installation_dir} to {package_dest_dir}')
        forcedrmdir(str(package_dest_dir))
        shutil.copytree(package_file_installation_dir, package_dest_dir)
        package_dest_file = Path(package_dest_dir, package_file)
        r = {
            'path': str(PurePosixPath(package_dest_file))
        }

        if (expand):
            installpath = Path(package_dest_dir, 'dist')
            r['installpath'] = str(PurePosixPath(installpath))
            r['dirname'] = os.path.splitext(package_file)[0]
            if (os.path.realpath(installpath) in EXPANDED_PACKAGE_FILES and os.path.exists(installpath)):
                logger.debug(f' -- {package_file_installation_dir} already expanded to {package_dest_dir}')
            else:
                forcedrmdir(str(installpath))
                logger.debug(f' -- expanding {package_dest_file} to {installpath}')
                extract(package_dest_file, installpath)
                EXPANDED_PACKAGE_FILES.append(os.path.realpath(installpath))
        return r


class ImageManager:
    def __init__(self, directory, package_manager: PackageManager):
        self.__images = set()
        self.__error_images = dict()
        self.__error_images_by_names = dict()
        self.__images_by_names = dict()
        self.__images_by_repos = dict()
        self.__package_manager = package_manager
        self.__directory = directory.resolve()
        self.__bom_server_url = self.getConfigurationValue('BOM_SERVER_URL')
        logger.debug('Reading "images" directory "%s"' % directory)
        for sub_directory, dirs, files in os.walk(directory):
            logger.debug('Reading sub-directory "%s" (with parent %s) which has %s dirs and %s files' % (sub_directory, Path(sub_directory).parent, dirs, files))
            if (Path(sub_directory).name == 'imageData'):
                for filename in files:
                    if (filename.endswith('.json')):
                        try:
                            f = Path(sub_directory, filename)
                            self.__addImage(f, package_manager)
                        except Exception as e:
                            # self.__error_images[f] = f'{e} {traceback.format_exc()}'
                            self.__error_images[f] = f'{e}'
                            if hasattr(e, 'imageName'):
                                self.__error_images_by_names[e.imageName] = e
                            logger.debug(f'File "{f}" is not a valid Image: {e}')

    @property
    def repo(self):
        return self.__package_manager.repo

    @property
    def configuration(self):
        return self.__package_manager.configuration

    def getConfigurationValue(self, key: str) -> Any:
        return self.__package_manager.getConfigurationValue(key)

    @property
    def size(self) -> int:
        """Total count of images"""
        return len(self.__images)

    def __addImage(self, file, package_manager: PackageManager):
        img = Image(file, package_manager)
        if (img.name in self.__images_by_names):
            raise KeyError('Image with name "%s" is already defined. This definition is skipped.' % img.name)
        self.__images.add(img)
        self.__images_by_names[img.name] = img
        rep = img.repository_name
        if rep in self.__images_by_repos:
            self.__images_by_repos[rep].append(img)
        else:
            self.__images_by_repos[rep] = [img]
        logger.debug("Adding : %s" % img)
        return img

    def countImagesWithSameRepo(self, image: 'Image'):
        if isinstance(image, Image):
            return len(self.__images_by_repos[image.repository_name])
        else:
            return -1

    def listImages(self, change_set: ChangeSet = None, touched: bool = False, packages=None):
        if (change_set or touched or packages):
            checked_folders = dict()
            return frozenset(i for i in self.__images if i.belongsTo(change_set, touched, checked_folders, packages))
        else:
            return copy.copy(self.__images)

    def getImage(self, image_name: str) -> Union['Image', None]:
        if image_name in self.__images_by_names:
            return self.__images_by_names[image_name]
        else:
            return None

    def findImage(self, predicate):
        if (not callable(predicate)):
            raise Exception('Predicate must be callable')
        return next((i for i in self.__images if predicate(i)), None)

    def findImages(self, predicate):
        if (not callable(predicate)):
            raise Exception('Predicate must be callable')
        return list(i for i in self.__images if predicate(i))

    def errors(self):
        """Returns all the error found in image JSON files"""
        return copy.copy(self.__error_images)

    def errorOnImage(self, imageName):
        """Returns the error found on a given image name"""
        if imageName in self.__error_images_by_names:
            return self.__error_images_by_names[imageName]

    def listImagesClassification(self, result: dict = None) -> dict:
        if (not isinstance(result, dict)):
            result = dict()
        for i in self.__images:
            if (i.product in result):
                row = result[i.product]
            else:
                row = dict()
                result[i.product] = row
            if (i.asset in row):
                row[i.asset].append(i)
            else:
                row[i.asset] = [i]
        return result


class ImageDefinitionError(os.error):
    """Exception raised for errors in the Image instanciation.

    Attributes:
        image -- Image in which the error occurred
        message -- explanation of the error
    """

    def __init__(self, image, message):
        self.image = image
        self.message = message

    @property
    def imageName(self):
        return self.image.name if self.image else None

    @property
    def imageFile(self):
        return self.image.file if self.image else None

    def __str__(self):
        return f'ImageDefinitionError: {self.message}'


class Image:
    def __init__(self, config_file, package_manager: PackageManager):
        self.__package_manager = package_manager
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
            data = orjson.loads(f.read())
        if ('imageData' not in data):
            raise ImageDefinitionError(self, 'Wrong JSON format, missing "imageData" top-level property')
        self.__image_folder = PurePosixPath(config_file).parents[1]
        self.__image_folder_git = package_manager.getGitRelativePath(self.__image_folder) + '/'
        self.__image_full_folder = Path(config_file).parents[1].absolute()
        self.__image_details = data['imageData']
        self._name = self.__image_details['name']
        if package_manager.registry_name:
            self._short_name = re.sub(rf'^{package_manager.registry_name}/', '', self._name)
        else:
            self._short_name = self._name
        image_tokens = self._name.split(':')
        if (len(image_tokens) > 2):
            raise ImageDefinitionError(self, f'Wrong image name "{self._name}", must in format "repository[:tag]"')
        self._image_repository_name = image_tokens[0]
        self._image_repository_tags = [image_tokens[1]] if len(image_tokens) > 1 else ['']
        if ('tags' in self.__image_details):
            self._image_repository_tags += self.__image_details['tags']
        self._auto_build = getBoolProperty(self.__image_details, 'autoBuild', False)
        self._auto_test = getBoolProperty(self.__image_details, 'autoTest', True)
        self._auto_push = getBoolProperty(self.__image_details, 'autoPush', False)
        self._auto_scan = getBoolProperty(self.__image_details, 'autoScan', True)
        self._vulnerabilities = None
        self._build_options = getArrayProperty(self.__image_details, 'buildOptions', [])
        self._dependencies = set()
        self._main_artifact = None
        self._dependencies_by_names = dict()
        self._dependencies_by_types = {
            TYPE_ARTIFACT: list(),
            TYPE_IMAGE: list()
        }
        self._dependencies_products = set()
        self._dependencies_assets = set()
        self._dependencies_versions = set()
        root_image_properties = filterDict(lambda k, v: k not in RESERVED_IMAGE_PROPERTIES, self.__image_details)
        root_image_properties['name'] = self._name
        self._image_info_dir = Path(IMAGEINFO_DIR, sanitizeDirectoryName(self._name))
        root_image_properties['buildTimestamp'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        root_image_properties['imageDataPath'] = str(PurePosixPath(self._image_info_dir))
        root_image_properties['COPY_IMAGE_INFO'] = f'COPY {root_image_properties["imageDataPath"]} /imageData'
        logger.debug(f'Adding image properties {root_image_properties}')
        self._renderer = TemplateRenderer(parent=package_manager.templateRenderer)
        self._renderer.addProperties(root_image_properties)
        if ('dependencies' in self.__image_details):
            logger.debug('Resolving dependencies for %s' % self._name)
            for dep in self.__image_details['dependencies']:
                dependency_name = dep['name']
                dependency_ref = dep['reference']
                dependency_ref_fallback = dep['referenceFallback'] if 'referenceFallback' in dep else None
                dependency_type = dep['type']
                dependency_download = getBoolProperty(dep, 'download', False)
                dependency_expand = getBoolProperty(dep, 'expand', False)
                if (not dependency_ref):
                    raise ImageDefinitionError(self, f'Missing "reference" for dependency in Image[{self._name}]')
                if (not dependency_name):
                    raise ImageDefinitionError(self, f'Missing "name" for dependency <{dependency_ref}> in Image[{self._name}]')
                elif (dependency_name in self._dependencies_by_names):
                    raise ImageDefinitionError(self, f'Already declared "{dependency_name}" dependency <{dependency_ref}> in Image[{self._name}]')
                logger.debug('.. resolving %s=%s' % (dependency_name, dependency_ref))
                p = package_manager.getPackage(dependency_ref)
                if p is None:
                    if not dependency_ref_fallback is None:
                        p = package_manager.getPackage(dependency_ref_fallback)
                        if p is None:
                            raise ImageDefinitionError(self, f'Dependency not found <{dependency_ref}> or <{dependency_ref_fallback}> in Image[{self._name}]')
                    else:
                        raise ImageDefinitionError(self, f'Dependency not found <{dependency_ref}> in Image[{self._name}]')
                if (p.type != dependency_type):
                    raise ImageDefinitionError(self, f'Wrong dependency "{dependency_name}" has type <{p.type}> but expected [{dependency_type}] in Image[{self._name}]')
                logger.debug(f'... found {p.name}')
                if (p.product):
                    self._dependencies_products.add(p.product)
                if (p.asset):
                    self._dependencies_assets.add(p.asset)
                if (p.version):
                    self._dependencies_versions.add(p.version)
                p.injectIntoRenderer(self._renderer, dependency_name)
                if p.type == TYPE_ARTIFACT:
                    if dependency_name.lower() == 'main' or ('main' in dep and dep['main']):
                        if self._main_artifact is None:
                            self._main_artifact = p
                        else:
                            raise ImageDefinitionError(self, f'There cannot be more than one "main" artifact, first one was: {self._main_artifact.name}')
                self._dependencies.add(p)
                self._dependencies_by_names[dependency_name] = {'ref': p, 'type': dependency_type, 'download': dependency_download, 'expand': dependency_expand}
                self._dependencies_by_types[p.type].append(p)
            if self._main_artifact is None and len(self._dependencies_by_types[TYPE_ARTIFACT]) == 1:
                self._main_artifact = self._dependencies_by_types[TYPE_ARTIFACT][0]
        self._result_image = package_manager.getPackage(self._name)
        if (self._result_image and self._result_image.type != TYPE_IMAGE):
            raise ImageDefinitionError(self, f'Image[{self._name}] error: image reference exists but has type <{self._result_image.type}> instead of <image>')
        # Properties 'product', 'asset', 'version', 'component' and 'env'
        # can be templated or inherited from the main component
        self.__consolidateSelfOrMainArtifactProperty('product', default='')
        self.__consolidateSelfOrMainArtifactProperty('asset', default='')
        self.__consolidateSelfOrMainArtifactProperty('version', default='')
        self.__consolidateSelfOrMainArtifactProperty('component', default=None)
        if 'environment' in self.__image_details and not 'env' in self.__image_details:
            self.__image_details['env'] = self.__image_details['environment']
        self.__consolidateSelfOrMainArtifactProperty('env', default='')

        if 'schemas' in self.__image_details:
            if isinstance(self.__image_details['schemas'], list):
                self.__schemas = frozenset(self.__image_details['schemas'])
            else:
                self.__schemas = frozenset([self.__image_details['schemas']])
        else:
            self.__schemas = frozenset()
        # See Labels convention at http://confluence.fircosoft.net/display/DTP/Shadoker+image+labels
        self.labels = {
            'org.label-schema.schema-version': '1.0.0-rc.1',
            'org.label-schema.vendor': 'Fircosoft',
            'org.label-schema.license': 'Fircosoft',
            'org.label-schema.name': f'{self.product} {self.asset} {self.component if self.component else ""} {self.version}',
            'org.label-schema.version': self.version,
           #'org.label-schema.build-date': TIMESTAMP_STR_NOW,
            'com.accuity.schema-version': 'ALC-1.0.0',
            'com.accuity.build-tool': 'shadoker',
            'com.accuity.product': self.product,
            'com.accuity.asset': self.asset,
            'com.accuity.version': self.version
        }
        if self.component:
            self.labels['com.accuity.component'] = self.component
        if self.__package_manager.repo:
           self.labels['org.label-schema.vcs-url'] = self.__package_manager.repo.remotes.origin.url
        if self.__package_manager.revision:
            self.labels['org.label-schema.vcs-ref'] = self.__package_manager.revision

        for schema_label in ('url', 'description', 'usage', 'docker.cmd', 'docker.cmd.devel', 'docker.cmd.test', 'docker.cmd.debug', 'docker.cmd.help', 'docker.params'):
            if schema_label in self.__image_details:
                self.labels[f'org.label-schema.{schema_label}'] = self.__image_details[schema_label]
        for accuity_label in ('os', 'team', 'projectName', 'projectUrl'):
            if accuity_label in self.__image_details:
                self.labels[f'com.accuity.{camelToKebabCase(accuity_label)}'] = self.__image_details[accuity_label]

        # TODO: externalize E2E-121 specific processing in a dedicacted class
        tag_e2e_121 = self.version
        if 'os' in self.__image_details:
            self.labels['com.accuity.os'] = self.__image_details['os']
            tag_e2e_121 = f"{tag_e2e_121}-{self.__image_details['os']}"
        if 'platform' in self.__image_details:
            self.labels['com.accuity.platform'] = self.__image_details['platform']
        a_env = getFirstMatch(self.__image_details, 'env', 'environment')
        if a_env:
            self.labels['com.accuity.environment'] = a_env
        elif not self._main_artifact is None and self._main_artifact.env:
            self.labels['com.accuity.environment'] = self._main_artifact.env

        if not self._main_artifact is None:
            a_repo = self._main_artifact.getProperty('repository')
            a_commit = None
            if a_repo:
                a_url = getFirstMatch(a_repo, 'url', 'uri')
                if a_url:
                    self.labels['com.accuity.product.vcs-url'] = a_url
                a_commit = getFirstMatch(a_repo, 'commit', 'ref')
                if a_commit:
                    self.labels['com.accuity.product.vcs-ref'] = a_commit
                if 'branch' in a_repo:
                    self.labels['com.accuity.product.vcs-branch'] = a_repo['branch']
            if not a_commit:
                a_commit = self._main_artifact.getProperty('commit')
                if a_commit:
                    self.labels['com.accuity.product.vcs-ref'] = a_commit
            a_build = self._main_artifact.getFirstProperty('buildUrl', 'build', 'build-url')
            if a_build:
                self.labels['com.accuity.product.build-url'] = a_build

        if 'thirdParties' in self.__image_details:
            thirdParties = self.__image_details['thirdParties']
            for t in thirdParties:
                self.labels[f'com.accuity.third-parties.{camelToKebabCase(t)}'] = thirdParties[t]
            # Warning: order matters for E2E-121 tag value
            if 'webServer' in thirdParties:
                tag_e2e_121 = f"{tag_e2e_121}-{thirdParties['webServer']}"
            if 'java' in thirdParties:
                tag_e2e_121 = f"{tag_e2e_121}-{thirdParties['java']}"
            if 'database' in thirdParties:
                tag_e2e_121 = f"{tag_e2e_121}-{thirdParties['database']}"
            if 'odbcManager' in thirdParties:
                tag_e2e_121 = f"{tag_e2e_121}-{thirdParties['odbcManager']}"
            if 'odbcClient' in thirdParties:
                tag_e2e_121 = f"{tag_e2e_121}-{thirdParties['odbcClient']}"
            if 'mqClient' in thirdParties:
                tag_e2e_121 = f"{tag_e2e_121}-{thirdParties['mqClient']}"

        coreengine_dependencies = list(filter(lambda p: p.type == TYPE_ARTIFACT and p.asset == 'coreengine', self._dependencies))
        coreengine_version = None
        if len(coreengine_dependencies) == 1:
            coreengine_version = coreengine_dependencies[0].version
        elif len(coreengine_dependencies) == 0:
            coreengine_dependencies = list(filter(lambda p: p.type == TYPE_IMAGE and p.asset == 'coreengine', self._dependencies))
            if len(coreengine_dependencies) == 1:
                coreengine_version = coreengine_dependencies[0].version
        if not coreengine_version is None:
            self.labels['com.accuity.dependencies.coreengine'] = f'COREENGINE{coreengine_version}'
            if not self.asset in ['coreengine']:
                tag_e2e_121 = f"{tag_e2e_121}-coreengine{coreengine_version}"

        filter_dependencies = list(filter(lambda p: p.type == TYPE_ARTIFACT and p.asset in ['filter_engine', 'filter-engine', 'FOF'], self._dependencies))
        if len(filter_dependencies) == 1:
            if not self.asset in ['filter-engine']:
                self.labels['com.accuity.dependencies.filter'] = f'FILTER{filter_dependencies[0].version}'
                tag_e2e_121 = f"{tag_e2e_121}-filter{filter_dependencies[0].version}"

        self._renderer.addProperty('_tag_e2e_121', tag_e2e_121)

    @property
    def name(self):
        return self._name

    @property
    def short_name(self):
        return self._short_name

    @property
    def repository_name(self):
        return self._image_repository_name

    @property
    def product(self) -> str:
        return self.__image_details['product']

    @property
    def asset(self) -> str:
        return self.__image_details['asset']

    @property
    def version(self) -> str:
        return self.__image_details['version']

    @property
    def component(self) -> str:
        return self.__image_details['component']

    @property
    def env(self) -> str:
        return self.__image_details['env']

    @property
    def dockerfile(self) -> str:
        if 'dockerfile' in self.__image_details:
            return self.__image_details['dockerfile']
        return 'Template.dockerfile'

    def __consolidateSelfOrMainArtifactProperty(self, prop: str, default, render: bool = True) -> str:
        if prop in self.__image_details:
            self.__image_details[prop] = self._renderer.renderString(self.__image_details[prop])
        elif self._main_artifact:
            if hasattr(self._main_artifact, prop):
                self.__image_details[prop] = getattr(self._main_artifact, prop)
                if self.__image_details[prop] is None:
                    self.__image_details[prop] = default
            else:
                self.__image_details[prop] = default
        else:
            self.__image_details[prop] = default

    @property
    def thirdParties(self) -> Dict[str, str]:
        if 'thirdParties' in self.__image_details:
            return self.__image_details['thirdParties']
        else:
            return dict()

    @property
    def tag(self) -> str:
        return self._image_repository_tags[0]

    @property
    def schemas(self):
        return self.__schemas

    def hasSchema(self, schema: str) -> bool:
        return schema in self.__schemas

    def getProperty(self, prop: str, default=None):
        return self.__image_details[prop] if (prop in self.__image_details) else default

    @property
    def folder(self):
        return self.__image_folder

    @property
    def file(self):
        return self.__config_file

    @property
    def gitPath(self):
        return self.__config_file_git

    @property
    def gitFolder(self):
        return self.__image_folder_git

    def match(self, matcher: ObjectMatcher):
        if matcher:
            return matcher.match(self.__image_details)
        return False

    def check(self):
        """Verifies all properties of this Images."""
        print('%s # %s' % (self, self._renderer.properties))

    def hook(self, step: str, result: build_result.BuildResult, env: dict, dry_run: bool = False) -> build_result.BuildResult:
        hook_script = Path('hooks', step)
        hook_commands = [hook_script]
        if (platform.system() == 'Windows'):
            hook_script = Path('hooks', step + '.exe')
            if (hook_script.exists()):
                hook_commands = [hook_script]
            else:
                hook_script = Path('hooks', step + '.bat')
                if (hook_script.exists()):
                    hook_commands = ['cmd.exe', '/c', hook_script]
                else:
                    hook_script = Path('hooks', step + '.cmd')
                    if (hook_script.exists()):
                        hook_commands = ['cmd.exe', '/c', hook_script]
                    else:
                        hook_script = Path('hooks', step + '.ps1')
                        if (hook_script.exists()):
                            hook_commands = ['powershell.exe', '-Command', f'try {{ {hook_script} }} catch {{ exit 666 }} exit $LASTEXITCODE']

        if (hook_script.exists()):
            try:
                result.logMessage(f' Hook script : {step}')
                hook_process = subprocess.run(hook_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=env, timeout=DEFAULT_TIMEOUT_SECONDS)
                if (hook_process.returncode != 0):
                    result.logError(' %s' % hook_process.stdout, hook_process.returncode)
                else:
                    result.logMessage(' %s' % hook_process.stdout)
            except subprocess.TimeoutExpired:
                result.logError(f' {step} hook timeout')
        return result

    def inspect(self, log=None, pull:bool=False):
        """Inspects actual Docker image in registry"""
        image_data = {
            'name': self._name,
            'product': self.product,
            'asset': self.asset,
            'version': self.version,
        }
        inspect_ok = False
        if (pull):
            pull_commands = ['docker', 'pull', self._name]
            pull_process = subprocess.run(pull_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
            if (pull_process.returncode != 0):
                if log:
                    log.logMessage(f' Warning: cannot pull {self._name} for inspection: {pull_process.stdout}')
        inspect_commands = ['docker', 'inspect', self._name, '--format', '{"digest":{{json .RepoDigests}}, "created":{{json .Created}}, "labels":{{json .Config.Labels}}}']
        inspect_process = subprocess.run(inspect_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        if (inspect_process.returncode == 0):
            try:
                image_cfg = orjson.loads(inspect_process.stdout)
                if (len(image_cfg['digest']) > 0):
                    inspect_ok = True
                    digest = image_cfg['digest'][0]
                    i = digest.index('@sha256:')
                    if (i >= 0):
                        digest = digest[i + 1:]
                    image_data['digest'] = digest
                    image_data['buildDate'] = fromDockerDatetime(image_cfg['created'])
                    image_data['labels'] = image_cfg['labels']
            except Exception:
                if (log):
                    log.logMessage(f' Warning: inspected image is not valid JSON {inspect_process.stdout}')
        else:
            if (log):
                log.logMessage(f' Warning: cannot inspect pushed image {inspect_process.stdout}')
        return (inspect_ok, image_data)

    def scan_vulnerabilities(self, result: build_result.BuildResult, env) -> bool:
        """Scan this Image for vulnerabilities with grype"""
        if not GRYPE_PATH:
            return False
        try:
            scan_commands = [GRYPE_PATH, self._name, "-o", "json"]
            scan_process = subprocess.run(scan_commands, stdout=subprocess.PIPE, universal_newlines=True, env=env)
            if scan_process.returncode != 0:
                result.logMessage(f' Image cannot be scanned: {scan_process.stdout}')
                return False
            else:
                raw_json = scan_process.stdout
                scan_info = orjson.loads(raw_json)
                self._vulnerabilities = {
                    'critical': [],
                    'high': [],
                    'medium': [],
                    'low': [],
                    'negligible': [],
                    'unknown': []
                }
                for v in scan_info['matches']:
                    if 'vulnerability' in v:
                        vuln = v['vulnerability']
                        sev = str.lower(vuln['severity'])
                        if sev in self._vulnerabilities:
                            self._vulnerabilities[sev].append(v)
                        else:
                            self._vulnerabilities[sev] = [v]
                testResult = TestResult(self._short_name, Path(self.__package_manager.configuration['ROOT'], 'reports').resolve())
                for sev in ('critical', 'high', 'medium', 'low', 'negligible', 'unknown'):
                    vulnerability_count = len(self._vulnerabilities[sev])
                    if vulnerability_count > 0:
                        test_message = f'{vulnerability_count} {sev} vulnerabilities'
                        if sev == 'critical' or sev == 'high':
                            for v in self._vulnerabilities[sev]:
                                test_message += f'\n - {v["vulnerability"]["id"]}'
                                package = getValue(v, 'artifact')
                                if isinstance(package, dict):
                                    test_message += f' : {getValue(package, "name")} {getValue(package, "version")}'
                                fix_version = getValue(v, 'vulnerability', 'fix', 'versions', 0)
                                if fix_version:
                                    print(f"FIX VERSION {fix_version}")
                                    test_message += f' (fixed in {fix_version})'
                                else:
                                    test_message += ' (not fixed)'
                            testResult.addTest(f'vulnerability.{sev}', test_message, TestStatus.FAILED)
                        else:
                            testResult.addTest(f'vulnerability.{sev}', f'{vulnerability_count} {sev} vulnerabilities', TestStatus.SKIPPED)
                    else:
                        testResult.addTest(f'vulnerability.{sev}', '', TestStatus.SUCCEEDED)
                testResult.dump()
                result.logMessage(f' Image scanned')
                return True
        except Exception as e:
            result.logMessage(f' Image cannot be scanned: {e}')
            return False

    def build(self, extra_tags: List[str] = [], dry_run: bool = False) -> build_result.BuildResult:
        """Builds this Image."""
        #from build_result import BuildResult
        result = build_result.BuildResult(self)
        result.logMessage(f'Building {self._name}')

        os.chdir(self.__image_full_folder)
        if (self._image_info_dir.exists()):
            forcedrmdir(self._image_info_dir)
        os.makedirs(self._image_info_dir, 0o777, True)
        shutil.copyfile(self.__config_file_abs, Path(self.__image_full_folder, self._image_info_dir, 'imageData.json'))
        do_build = True
        build_env = dict(os.environ)
        # Adding Shadoker environment variables.
        # Warning, all values MUST be strings (number, None or objects are breaking the subprocess.run() method)
        build_env[f'{SHADOKER_VAR_PREFIX}IMAGE_NAME'] = self.name
        build_env[f'{SHADOKER_VAR_PREFIX}IMAGE_PRODUCT'] = self.product
        build_env[f'{SHADOKER_VAR_PREFIX}IMAGE_ASSET'] = self.asset
        build_env[f'{SHADOKER_VAR_PREFIX}IMAGE_VERSION'] = self.version

        # Extracts all required dependencies and their properties
        for dep_key in self._dependencies_by_names:
            dep = self._dependencies_by_names[dep_key]
            ref = dep['ref']
            result.logMessage(f' Checking dependency "{dep_key}" type {dep["type"]} download={dep["download"]} expand={dep["expand"]}')
            os.makedirs(Path(self._image_info_dir, dep_key), 0o777, True)
            shutil.copy(ref.config_file_abs, Path(self._image_info_dir, dep_key, os.path.basename(ref.config_file)))
            if (dep['type'] == TYPE_ARTIFACT):
                if (dep['download'] or dep['expand']):
                    result.logMessage(f'  Downloading "{dep_key}" package {ref} -> {ref.uri}')
                    if (dep['expand']):
                        result.logMessage(f'  Expanding "{dep_key}" package archive file')
                    try:
                        dep_props = ref.download(PACKAGE_INSTALLDIR, dep['expand'])
                        result.logMessage(f'  Reference "{dep_key}" available at {dep_props}')
                        self._renderer.addProperty(f'{DEPENDENCY_PROPERTY_KEY}.{dep_key}', dep_props)
                    except Exception as ex:
                        result.logError(f'  Error while downloading "{dep_key}" package {ref.uri} : {ex}')
                        do_build = False
            elif dep['type'] == TYPE_IMAGE:
                pull_command = ['docker', 'pull', '-q', ref.name]
                result.logMessage(f' Executing {pull_command}')
                pull_process = subprocess.run(pull_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
                if (pull_process.returncode != 0):
                    result.logError(' %s' % pull_process.stdout, pull_process.returncode)
                else:
                    result.logMessage(' %s' % pull_process.stdout)

        # Generate Dockerfile from template if necessary
        dockerfile = 'Dockerfile'
        template_dockerfile = self.dockerfile
        if (Path(template_dockerfile).exists()):
            result.logMessage(f' Found "{template_dockerfile}"')
            dockerfile = f'Dockerfile.exp.{hash(self._name)}'
            if (Path(dockerfile).exists()):
                result.logMessage(f' Warning on "{template_dockerfile}", there is already a "{dockerfile}" which will be replaced.')
                # do_build = False
            if (do_build):
                self._renderer.renderFile(Path(template_dockerfile), Path(dockerfile))
        elif (Path(dockerfile).exists()):
            result.logMessage(f' Found "{dockerfile}"')
        else:
            do_build = False
            result.logError(f' Missing "{dockerfile}"')

        tags = set(self._renderer.renderStrings(self._image_repository_tags + extra_tags, True))
        print('TAGS:', self._image_repository_tags, ' -> ', tags)
        # Prepare the build command
        if (self._auto_build):
            result.logMessage(' Using auto-build of Dockerfile')
            build_commands = ['docker', 'build']
            build_commands += self._build_options
            build_commands += ['-f', dockerfile]
            for la in self.labels:
                build_commands.append('--label')
                build_commands.append(f'{la}={self.labels[la]}')
            for t in tags:
                build_commands.append('-t')
                if (t):
                    build_commands.append(f'{self._image_repository_name}:{t}')
                else:
                    build_commands.append(self._image_repository_name)
            build_commands.append('.')
        else:
            build_script = 'buildDockerImageFromDependencies.sh' if (platform.system() != 'Windows') else 'buildDockerImageFromDependencies.bat'
            if (Path(build_script).exists()):
                result.logMessage(f' Found script "{build_script}"')
                imageData = os.path.basename(os.path.splitext(self.__config_file)[0])
                if (platform.system() == 'Windows'):
                    build_commands = [build_script, '--imageData', imageData]
                else:
                    build_commands = ['/usr/bin/bash', build_script, '--imageData', imageData]
            else:
                result.logError(f' Missing script "{build_script}"')
                do_build = False

        push_commands = []
        if (self._auto_push):
            for t in tags:
                if (t):
                    push_commands.append(['docker', 'push', f'{self._image_repository_name}:{t}'])
                else:
                    push_commands.append(['docker', 'push', self._image_repository_name])

        if (do_build):
            # HOOK-1 Running 'pre_build' hook if available
            if (self.hook('pre_build', result, build_env, dry_run).isFailed()):
                result.logMessage(' Aborting build because failed pre_build step')
                return result
            result.logMessage(f' Executing {build_commands}')
            # BUILD phase
            build_process = subprocess.run(build_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
            if (build_process.returncode != 0):
                result.logError(' %s' % build_process.stdout, build_process.returncode)
            else:
                result.logMessage(' %s' % build_process.stdout)
                # BOM phase
                bom_server_url = self.__package_manager.getConfigurationValue("BOM_SERVER_URL")
                if bom_server_url and SYFT_PATH:
                    try:
                        scan_commands = [SYFT_PATH, self._name, "-o", "cyclonedx-json"]
                        scan_process = subprocess.run(scan_commands, stdout=subprocess.PIPE, universal_newlines=True, env=build_env)
                        if scan_process.returncode != 0:
                            result.logMessage(f' CycloneDX BOM cannot be generated: {scan_process.stdout}')
                        else:
                            result.logMessage(' CycloneDX BOM generated')
                            raw_json = scan_process.stdout
                            bom_info = orjson.loads(raw_json)
                            bom_info_version = bom_info['metadata']['component']['version']
                            bom_info['metadata']['component']['group'] = f'fircosoft.{self.product}.{self.asset}'
                            bom_info['serialNumber'] = sha256toUUIDurn(bom_info_version)
                            bom_details = f"CycloneDX BOM {bom_info['serialNumber']} (group={bom_info['metadata']['component']['group']} / {len(bom_info['components'])} components)"
                            try:
                                req = urllib.request.Request(url=f'{bom_server_url}/bom', data=orjson.dumps(bom_info), method='POST', headers={'Content-Type': 'application/vnd.cyclonedx+json; version=1.3', 'Accept' : '*/*'})
                                with urllib.request.urlopen(req) as f:
                                    pass
                                result.logMessage(f" {bom_details} pushed to repository {f.status} {f.reason}")
                            except urllib.error.URLError as e:
                                result.logMessage(f' Cannot push {bom_details} to repository: {e}')
                    except Exception as e:
                        result.logMessage(f' CycloneDX BOM cannot be generated: {e}')
                # VULNERABILITY SCAN phase
                if self._auto_scan and GRYPE_PATH:
                    self.scan_vulnerabilities(result, build_env)
                # HOOK-2 Running 'post_build' hook if available
                if (self.hook('post_build', result, build_env, dry_run).isFailed()):
                    result.logMessage(' Aborting build because failed post_build step')
                    return result
                test_ok_count = 0
                test_failed_count = 0
                test_files = glob.glob('*.test.yml') if self._auto_test else []
                if len(test_files) > 0:
                    # HOOK-3 Running 'pre_test' hook if available
                    if (self.hook('pre_test', result, build_env, dry_run).isFailed()):
                        result.logMessage(' Aborting build because failed pre_test step')
                        return result
                for test_file in test_files:
                    if (test_file.endswith('.template.test.yml')):
                        real_test_file = test_file[:-18] + '.test.yml-' + randomindex()
                        if (Path(real_test_file).exists()):
                            result.logMessage(f' Conflict on "{test_file}", there is also a "{real_test_file}" which will be replaced.')
                            # do_build = False
                        self._renderer.renderFile(test_file, real_test_file)
                    else:
                        real_test_file = test_file
                    build_test_command = ['docker-compose', '-f', real_test_file, 'build', '--force-rm', '--no-cache']
                    build_test_process = subprocess.run(build_test_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
                    if (build_test_process.returncode != 0):
                        result.logError(f' Testing {test_file} FAILED during build: {build_test_process.stdout}', build_test_process.returncode)
                        test_failed_count += 1
                    else:
                        test_command = ['docker-compose', '-f', real_test_file, 'run', '--rm', 'sut']
                        test_process = subprocess.run(test_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env, timeout=DEFAULT_TIMEOUT_SECONDS)
                        if (test_process.returncode != 0):
                            result.logError(f' Testing {test_file} FAILED : {test_process.stdout}', test_process.returncode)
                            test_failed_count += 1
                        else:
                            test_ok_count += 1
                            result.logMessage(f' Testing {test_file} OK : {test_process.stdout}')
                        stop_test_process = subprocess.run(['docker-compose', '-f', real_test_file, 'rm', '--force', '--stop'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env, timeout=DEFAULT_TIMEOUT_SECONDS)
                        if (stop_test_process.returncode != 0):
                            result.logMessage(f' Warning: issue while stoping test : {stop_test_process.stdout}')
                    if (real_test_file != test_file):
                        try:
                            os.remove(real_test_file)
                        except Exception:
                            result.logMessage(f' Warning: could not delete intermediary file {real_test_file}')
                if (len(test_files) > 0):
                    build_env[f'{SHADOKER_VAR_PREFIX}TEST_FAILED'] = str(test_failed_count)
                    build_env[f'{SHADOKER_VAR_PREFIX}TEST_OK'] = str(test_ok_count)
                    # HOOK-4 Running 'post_test' hook if available
                    if (self.hook('post_test', result, build_env, dry_run).isFailed()):
                        result.logMessage(' Aborting build because failed post_test step')
                        return result
                if (test_failed_count == 0):
                    push_ok = False
                    if (dry_run and ('_forcePush' not in self.__image_details or not self.__image_details['_forcePush'])):
                        for push_command in push_commands:
                            result.logMessage(f' Dry-run, skipping {push_command}')
                    else:
                        # HOOK-5 Running 'pre_push' hook if available
                        if (self.hook('pre_push', result, build_env, dry_run).isFailed()):
                            result.logMessage(' Aborting build because failed pre_push step')
                            return result
                        for push_command in push_commands:
                            result.logMessage(f' Executing {push_command}')
                            push_process = subprocess.run(push_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, env=build_env)
                            if (push_process.returncode == 0):
                                push_ok = True
                                result.logMessage(' %s' % push_process.stdout)
                            else:
                                result.logError(' %s' % push_process.stdout, push_process.returncode)
                    if (push_ok):
                        # Inspecting image in Docker registry to get its digest, labels and timestamp
                        inspect_ok, image_data = self.inspect(result)
                        if (inspect_ok):
                            image_data['product'] = self.product
                            image_data['asset'] = self.asset
                            image_data['version'] = self.version
                            # Declaring environment variables for digest and labels
                            build_env[f'{SHADOKER_VAR_PREFIX}IMAGE_DIGEST'] = image_data['digest']
                            for label in image_data['labels']:
                                sanitized_label = sanitizeEnvironmentVariable(label)
                                build_env[f'{SHADOKER_VAR_PREFIX}IMAGE_LABEL_{sanitized_label}'] = str(image_data['labels'][label])
                        # HOOK-6 Running 'post_push' hook if available
                        if (self.hook('post_push', result, build_env, dry_run).isFailed()):
                            result.logMessage(' Warning: failed post_push step')
                        # Now updating reference for the image that has just been pushed
                        if (inspect_ok):
                            result.logMessage(f' Referencing image {image_data}')
                elif (len(push_commands) > 0):
                    result.logMessage(' Skipping push because of test errors')
        else:
            result.logMessage(' Skipping build because of unmet requirements')
        result.end()
        return result

    def belongsTo(self, change_set: ChangeSet, touched: bool, check_folder: dict, packages: set = None):
        """Is this image is part of a given ChangeSet ?
          Method checks image definition and associated folder,
          and if any of its dependencies is within a given set of packages."""
        if packages:
            if packages.intersection(self._dependencies):
                return True
        if change_set:
            if change_set.isChangedFile(self.__config_file):
                return True
            if touched and change_set.isTouchedFile(self.__config_file):
                return True
            if self.__image_folder in check_folder:
                if check_folder[self.__image_folder]:
                    return True
            else:
                if change_set.isChangedFolder(self.__image_folder, 'imageData', PATTERN_MANIFEST):
                    check_folder[self.__image_folder] = True
                    return True
                if touched and change_set.isTouchedFolder(self.__image_folder, 'imageData', PATTERN_MANIFEST):
                    check_folder[self.__image_folder] = True
                    return True
                check_folder[self.__image_folder] = False
            return False
        return True

    def __str__(self):
        s = f'Image[{self._name}]'
        if self._vulnerabilities:
            critical = len(self._vulnerabilities['critical'])
            high = len(self._vulnerabilities['high'])
            if critical + high > 0:
                s += ' {vuln:'
                if critical > 0:
                    s += f' {critical} crit'
                if high > 0:
                    if critical > 0:
                        s += ','
                    s += f' {high} high'
                s += '}'
        return s
