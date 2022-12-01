import getopt
import json
import logging
import os
import subprocess
import sys
import time
import traceback
from collections.abc import Collection
from pathlib import Path
from git import Repo
from typing import Union

from git.remote import PushInfo

try:
    from shadoker.__logging__ import command_logger
except:
    sys.path.insert(1, str(Path(os.path.dirname(__file__), '..').resolve()))
    from shadoker.__logging__ import command_logger
from shadoker.package_manager import SHADOKER_VAR_PREFIX, PackageManager, ImageManager, Image, TYPE_ARTIFACT, TYPE_IMAGE
from shadoker.build_result import BuildResult, BuildStatus
from shadoker.change_set import ChangeSet
from shadoker.image_E2E_validator import validateE2E
from shadoker.manifest_manager import ManifestManager
from shadoker.chart_manager import ChartManager, Chart
from shadoker.object_matcher import ObjectMatcher
from shadoker.template_renderer import TemplateRenderer
from shadoker.shadoker_globals import sanitizeArgument
from shadoker.report_helpers import OutputFormat, beginHtmlReportTable, addHtmlReportTableData, addHtmlReportTableDataError, endHtmlReportTable, beginCsvReportTable, addCsvReportTableData, endCsvReportTable

logging.basicConfig(level=logging.INFO)

TARGET_HELP = 'help'
TARGET_PACKAGE = 'package'
TARGET_DOCKER = 'docker'
TARGET_CHANGE = 'change'
TARGET_ASSET = 'asset'
TARGET_CHART = 'chart'
TARGET_MANIFEST = 'manifest'
ALL_TARGETS = [TARGET_HELP, TARGET_PACKAGE, TARGET_DOCKER, TARGET_CHANGE, TARGET_ASSET, TARGET_MANIFEST, TARGET_CHART]
COMMAND_LIST, COMMAND_LIST_SHORT = ('list', 'ls')
COMMAND_UPDATE, COMMAND_UPDATE_SHORT = ('update', 'upd')
COMMAND_BUILD = 'build'
COMMAND_INSPECT = 'inspect'
COMMAND_IMPACTED, COMMAND_IMPACTED_SHORT = ('impacted', 'imp')
ALL_IMAGES_FILE = '.all_images.json'

GLOBAL_PROPERTIES = dict()


def usage(exit_code, msg=''):
    if (msg):
        print(msg)
    print('USAGE: %s <target> <command> [<options>]' % 'shadoker')
    print('  where target can be either:')
    print('          - %s : to get this help documentation' % TARGET_HELP)
    print('          - %s : to perform actions on the referenced packages' % TARGET_PACKAGE)
    print('          - %s : to perform actions on the defined Docker images' % TARGET_DOCKER)
    print('          - %s : to list changes on packages, images and files' % TARGET_CHANGE)
    print('          - %s : to list all declared assets and products across images and packages' % TARGET_ASSET)
    print('  where command can be either:')
    print('          - %s : to list the corresponding items, according to the optional parameters in the command' % COMMAND_LIST_SHORT)
    print('          - %s : to verify the validity of the items' % COMMAND_INSPECT)
    print('  specific commands for "docker" are:')
    print('          - %s : to list the impacted Docker images, either because they were directly modified or their dependencies have been modified' % COMMAND_IMPACTED_SHORT)
    print('          - %s <img> : show details of a given Docker image' % COMMAND_INSPECT)
    print('          - %s [<img>]: build one given Docker image or all matching ones' % COMMAND_BUILD)
    print('          - %s [<img>]: update one or more given Image references with the corresponding Docker registry information' % COMMAND_UPDATE)
    print('  where options are:')
    print('          -r <RootDirectory> : set Root directory where to find references/ and docker/ folders. Default is current directory')
    print('          --config <ConfigurationFile> : use this configuration file instead. Default "" in the root ')
    print('          -s <StartRevision> : the commit revision where to start looking for items. Default is the beginning of tree')
    print('          -e <EndRevision> : the commit revision where to stop looking for items. Default is the HEAD commit')
    print('          -t : also includes modified items (i.e. modified but not yet in the index or not tracked), in addition to the changeset between revisions')
    print('          -c : also includes "staged" items (i.e. modified in the index but not yet committed), in addition to the changeset between revisions')
    print('          -w : shows package or image errors details, can be used with %s command for instance' % COMMAND_LIST_SHORT)
    print('          -W : shows only errors in packages or images, can be used with %s command' % COMMAND_LIST_SHORT)
    print('          -l <log_file> : log output in the specified file')
    print('          -v : verbosity, can be DEBUG, INFO, WARN or ERROR')
    print('          -b <BuildIndex> : optional build index that will be appended in image tags')
    print('          -d : dry-run, do not push any build image or execute any integration')
    print('          -o : output-format, default to TEXT but can also be CSV, HTML or METRICS')
    print('          -x : execute, run the specified script for each reported item. This option can be used with the `%s` command on "%s".' % (COMMAND_UPDATE, TARGET_DOCKER))
    sys.exit(exit_code)

def error_text(s):
    return f'\033[91m{s}\033[0m'

def success_text(s):
    return f'\033[92m{s}\033[0m'

def warning_text(s):
    return f'\033[93m{s}\033[0m'

def print_error(s):
    print(error_text(s))

def print_warning(s):
    print(success_text(s))

def print_success(s):
    print(success_text(s))

def toBoolean(s: str, default_value: bool = None):
    if (not s and default_value is not None):
        return default_value
    return s.lower() in ['true', '1', 't', 'y', 'yes']

def counted(count: Union[int, list, dict], label: str) -> str:
    if (isinstance(count, Collection)):
        count = len(count)
    if (count == 0):
        return f'no {label}'
    elif (count == 1):
        return f'1 {label}'
    else:
        if (label.endswith('s')):
            return f'{count} {label}'
        else:
            return f'{count} {label}s'

def resolve_global_property(property: str, default_value, config: dict, config_var: str, env_var: str):
    if isinstance(config, dict) and config_var in config:
        GLOBAL_PROPERTIES[property] = config[config_var]
    elif env_var in os.environ:
        GLOBAL_PROPERTIES[property] = os.environ[env_var]
    else:
        GLOBAL_PROPERTIES[property] = default_value

class DummyRepo:
    def __init__(self, repo: str):
        self._repo = repo
    def __enter__(self):
        pass
    def __exit__(self, *exc):
        pass

# Main program
def main():
    root_directory = '.'
    config_file = 'shadoker-config.json'
    config = dict()
    if Path(config_file).exists():
        try:
            with open(config_file) as f:
                config = json.load(f)
        except Exception as e:
            print(f'Warning: configuration file {config_file} cannot be read correctly {e}')
    resolve_global_property('DOCKER_REGISTRY', '', config, 'dockerRegistry', 'DOCKER_REGISTRY')
    resolve_global_property('BOM_SERVER_URL', '', config, 'bomServerUrl', 'BOM_SERVER_URL')
    start = None
    end = None
    touched = False
    staged = False
    show_errors = False
    only_errors = False
    exit_code = 0
    match_expression = ObjectMatcher()
    update_data = None
    build_index = ''
    metrics_prefix = ''
    dry_run = False
    output_format = OutputFormat.TEXT
    execute_script = None
    commit_all = False
    create_if_missing = False
    force_pull = False
    configure_cmd_log = True
    try:
        target = sys.argv[1].lower()
        if (target not in ALL_TARGETS):
            usage(2, 'ERROR: unknown target "%s"' % target)
        if (target == TARGET_HELP):
            usage(0)
        if (len(sys.argv) < 3):
            usage(2, f'ERROR: missing command after "{target}"')
        cmd = sys.argv[2].lower()
        if (not target or not cmd or target[0] == '-' or cmd[0] == '-'):
            usage(2)
        opts, args = getopt.getopt(sys.argv[3:], 'hr:s:e:tcawWv:m:f:u:b:p:do:x:kl:', ['root=', 'start=', 'end=', 'verbose=', 'match=', 'filter=', 'update-data=', 'config=', 'build=', 'prefix=', 'output-format=', 'execute=', 'commit-all=', 'create=', 'force-pull', 'log-file='])
    except Exception as e:
        print(e)
        usage(2)
    for opt, arg in opts:
        if opt in ("-r", "--root"):
            root_directory = arg
        elif opt in ("--config"):
            config_file = arg
        elif opt in ("-s", "--start"):
            start = arg
        elif opt in ("-e", "--end"):
            end = arg
        elif opt in ("-t", "--touched"):
            touched = toBoolean(arg, True)
        elif opt in ("-c", "--cached"):
            staged = toBoolean(arg, True)
        elif opt in ("-w", "--warn_errors"):
            show_errors = toBoolean(arg, True)
        elif opt in ("-W", "--only-errors"):
            show_errors = True
            only_errors = True
        elif opt in ("-d", "--dry-run"):
            dry_run = toBoolean(arg, True)
        elif opt in ("-a", "--commit-all"):
            commit_all = toBoolean(arg, True)
        elif opt in ("-v", "--verbose"):
            if (arg.upper() == 'INFO'):
                logging.basicConfig(level=logging.INFO)
            elif (arg.upper() == 'WARN'):
                logging.basicConfig(level=logging.WARN)
            elif (arg.upper() == 'DEBUG'):
                os.environ['GIT_PYTHON_TRACE'] = '0'
                logging.basicConfig(level=logging.DEBUG)
            elif (arg.upper() == 'ERROR'):
                logging.basicConfig(level=logging.ERROR)
            else:
                logging.basicConfig(level=logging.INFO)
        elif opt in ("-m", "--match"):
            try:
                if (arg[0] == '@'):
                    with open(arg[1:]) as match_file:
                        r, m = match_expression.addCriteria(json.load(match_file))
                else:
                    r, m = match_expression.addCriteria(json.loads(arg))
                if (not r):
                    usage(2, 'ERROR: "match" parameter has %s' % m)
            except Exception:
                usage(2, 'ERROR: "match" parameter must be valid JSON but is %s' % arg)
        elif opt in ("-f", "--filter"):
            k, v = arg.split('=')
            if (not k or not v):
                usage(2, 'ERROR: "filter" parameter must be in the form key=value')
            r, m = match_expression.addCriteria(k, v)
            if (not r):
                usage(2, 'ERROR: "filter" parameter has %s' % m)
        elif opt in ("-u", "--update-data"):
            if (cmd not in ['upd', 'update']):
                usage(2, 'ERROR: "update-data" parameter can only be used with the update command')
            try:
                if (arg[0] == '@'):
                    with open(arg[1:]) as update_file:
                        update_data = json.load(update_file)
                else:
                    update_data = json.loads(arg)
                if (len(update_data) == 1 and 'artifact' in update_data):
                    update_data = update_data['artifact']
            except Exception:
                usage(2, f'ERROR: "update-data" parameter must be valid JSON but is {arg}')
        elif opt in ("-b", "--build"):
            build_index = arg
        elif opt in ("-p", "--prefix"):
            metrics_prefix = arg
        elif opt in ("-o", "--output-format"):
            output_format = OutputFormat.parse(arg)
        elif opt in ("-x", "--execute"):
            execute_script = arg
        elif opt in ("-k", "--create"):
            print(f'CREATE arg {arg}')
            create_if_missing = toBoolean(arg, True)
        elif opt == '--force-pull':
            force_pull = True
        elif opt in ('-l', '--log-file'):
            configure_cmd_log = False
            filehandler = logging.FileHandler(arg, 'w')
            filehandler.setFormatter(logging.Formatter('%(message)s'))
            command_logger.addHandler(filehandler)
    need_change_set = True
    if (start):
        if (not end):
            end = 'HEAD'
    elif (end):
        start = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
    elif (touched):
        usage(2, 'ERROR: -t parameter requires either -s or -e or both')
    else:
        need_change_set = False
    os.environ["TZ"] = "UTC"
    GLOBAL_PROPERTIES['ROOT'] = str(Path(root_directory).absolute())
    TEMPLATE_RENDERER_ROOT = TemplateRenderer(config_file)
    if (build_index):
        TEMPLATE_RENDERER_ROOT.addProperty('BUILD_INDEX', build_index)
    if (end and end != 'HEAD'):
        TEMPLATE_RENDERER_ROOT.addProperty('REVISION', end)
    os.environ[f'{SHADOKER_VAR_PREFIX}_SCRIPT_PATH'] = str(Path(root_directory, 'scripts').absolute())
    # with DummyRepo(root_directory) as REPO: # use this to test without git information
    with Repo(root_directory) as REPO:
        CHANGES = None
        if (need_change_set):
            try:
                CHANGES = ChangeSet(REPO, start, end)
            except Exception:
                print('ERROR: cannot create ChangeSet from %s to %s' % (start, end))
                return 2
        if target == TARGET_MANIFEST:
            MANIFEST_MANAGER = ManifestManager(REPO, Path(root_directory, 'docker') )
            manifests = MANIFEST_MANAGER.listManifests(CHANGES, touched, staged)
            indexes = MANIFEST_MANAGER.listIndexes(CHANGES, touched, staged)
            if cmd in [COMMAND_LIST, COMMAND_LIST_SHORT]:
                banner_message = 'Listing manifests'
                if (CHANGES):
                    banner_message += ' within %s' % CHANGES
                    if (touched):
                        banner_message += ', including modified'
                if (staged):
                    banner_message += ', including staged'
                if (match_expression.hasCriteria):
                    banner_message += f' matching criteria {match_expression}'
                print(banner_message)
                if (len(manifests) > 0):
                    print(' * %s' % ('\n * ').join((str(m) for m in manifests)))
                print(f'Found {counted(manifests, "manifest")}')
                banner_message = 'Listing manifest indexes'
                if (CHANGES):
                    banner_message += ' within %s' % CHANGES
                    if (touched):
                        banner_message += ', including modified'
                if (staged):
                    banner_message += ', including staged'
                if (match_expression.hasCriteria):
                    banner_message += f' matching criteria {match_expression}'
                print(banner_message)
                if (len(indexes) > 0):
                    print(' * %s' % ('\n * ').join((str(m) for m in indexes)))
                print(f'Found {counted(indexes, "manifest indexes")}')
            elif cmd in [COMMAND_UPDATE, COMMAND_UPDATE_SHORT]:
                try:
                    MANIFEST_MANAGER.updateManifests(CHANGES, touched, staged)
                except Exception as ex:
                    exit_code = 2
                    print('ERROR: while updating manifests %s' % ex)
            else:
                usage(2, f'ERROR: unknown {TARGET_MANIFEST} command "{cmd}"')
            return exit_code
        PACKAGE_MANAGER = PackageManager(REPO, Path(root_directory, 'references'), TEMPLATE_RENDERER_ROOT, GLOBAL_PROPERTIES)
        if (target == TARGET_PACKAGE):
            packages = PACKAGE_MANAGER.listPackages(CHANGES, touched, staged)
            package_errors = PACKAGE_MANAGER.errors()
            if cmd in [COMMAND_LIST, COMMAND_LIST_SHORT]:
                # List one or multiple packages matching given criteria
                banner_message = 'Listing packages'
                if show_errors:
                    print('Found %s in packages:' % (counted(package_errors, 'error')))
                    if len(package_errors) > 0:
                        exit_code = 11
                        print(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in package_errors.items())))
                if (CHANGES):
                    banner_message += ' within %s' % CHANGES
                    if (touched):
                        banner_message += ', including modified'
                if (staged):
                    banner_message += ', including staged'
                if (match_expression.hasCriteria):
                    banner_message += ' matching criteria %s' % match_expression
                    packages = list(filter(lambda p: p.match(match_expression), packages))
                if (args):
                    if (len(args) > 1):
                        usage(2, 'ERROR: only one package name should be specified')
                    package_name = args[0]
                    banner_message += ' named "%s"' % package_name
                    packages = list(filter(lambda p: p.name.startswith(package_name), packages))
                print(banner_message)
                if len(packages) > 0 and not only_errors:
                    print(' * %s' % ('\n * ').join((str(s) for s in packages)))
                print('Found %d packages (%s):' % (len(packages), counted(package_errors, 'error')))
                command_logger.info('\n'.join(p.name for p in packages))
            elif (cmd in ['inspect']):
                # Inspect one or multiple packages matching given criteria
                lines = list()
                if (output_format == OutputFormat.TEXT):
                    lines.append('Inspecting packages')
                elif (output_format == OutputFormat.HTML):
                    lines = beginHtmlReportTable(lines, 'pkguri', 'Package', 'Status', 'URL', 'Error')
                if (show_errors):
                    if (output_format == OutputFormat.TEXT):
                        lines.append('Found %s in packages:' % (counted(package_errors, 'error')))
                    if (len(package_errors) > 0):
                        exit_code = 11
                        if (output_format == OutputFormat.TEXT):
                            lines.append(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in package_errors.items())))
                if (CHANGES):
                    if (output_format == OutputFormat.TEXT):
                        lines[0] += ' within %s' % CHANGES
                        if (touched):
                            lines[0] += ', including modified'
                if (staged):
                    if (output_format == OutputFormat.TEXT):
                        lines[0] += ', including staged'
                if (match_expression.hasCriteria):
                    if (output_format == OutputFormat.TEXT):
                        lines[0] += ' matching criteria %s' % match_expression
                    packages = list(filter(lambda p: p.match(match_expression), packages))
                if (args):
                    if (len(args) > 1):
                        usage(2, 'ERROR: only one package name should be specified')
                    package_name = args[0]
                    if (output_format == OutputFormat.TEXT):
                        lines[0] += ' named "%s"' % package_name
                    packages = list(filter(lambda p: p.name.startswith(package_name), packages))
                # Inspect only "artifact" packages, omit "image" for the moment
                packages = list(filter(lambda p: p.type == 'artifact', packages))
                if (len(packages) > 0):
                    package_ok_count = 0
                    package_failed_count = 0
                    for p in packages:
                        if (p.type == 'artifact'):
                            status, message = p.inspect()
                            if (status):
                                package_ok_count += 1
                                if (output_format == OutputFormat.TEXT):
                                    lines.append(f' * OK   : {p.name}')
                                elif (output_format == OutputFormat.HTML):
                                    lines = addHtmlReportTableData(lines, p.name, 'OK', p.uri, '')
                            else:
                                package_failed_count += 1
                                if (output_format == OutputFormat.TEXT):
                                    lines.append(f' * FAIL : {p.name} ({message})')
                                elif (output_format == OutputFormat.HTML):
                                    lines = addHtmlReportTableDataError(lines, p.name, 'FAIL', p.uri, message)
                    if (output_format == OutputFormat.TEXT):
                        lines.append(f' Found {len(packages)} "artifact" packages ({counted(package_errors, "error")}) : {package_failed_count} bad URLs')
                    elif (output_format == OutputFormat.HTML):
                        lines = endHtmlReportTable(lines)
                    if package_failed_count > 0:
                        exit_code = 2
                else:
                    if (output_format == OutputFormat.TEXT):
                        lines.append(' Found no matching "artifact" package to inspect')
                print('\n'.join(lines))
            elif cmd in [COMMAND_UPDATE_SHORT, COMMAND_UPDATE]:
                # Update one or more packages
                if not update_data:
                    usage(2, 'ERROR: update command requires some "update-data" parameter')
                list_update = isinstance(update_data, list)
                if list_update:
                    banner_message = 'Updating listed packages'
                    print("MULTI PACKAGE UPDATE")
                else:
                    banner_message = 'Looking for a package'
                if CHANGES:
                    banner_message += f' within {CHANGES}'
                    if touched:
                        banner_message += ' including modified'
                if match_expression.hasCriteria:
                    if list_update:
                        usage(2, 'ERROR: for list update no package search criteria should be specified')
                    banner_message += f' matching criteria {match_expression}'
                    packages = list(filter(lambda p: p.match(match_expression), packages))
                if args:
                    if list_update:
                        if len(args) == 1 and args[0] == '*' or args[0] == '':
                            pass
                        else:
                            usage(2, 'ERROR: for list update no package name should be specified')
                    if len(args) > 1:
                        usage(2, 'ERROR: only one package name should be specified')
                    package_name = args[0]
                    banner_message += f' named "{package_name}"'
                    package = PACKAGE_MANAGER.getPackage(package_name)
                    if not package is None and package in packages:
                        packages = [package]
                    else:
                        packages = list(filter(lambda p: p.name.startswith(package_name), packages))
                print(banner_message)
                if (len(packages) > 0):
                    print(' * %s' % ('\n * ').join((str(s) for s in packages)))
                print('Found %d packages (%s):' % (len(packages), counted(package_errors, 'error')))
                if list_update:
                    for data in update_data:
                        PACKAGE_MANAGER.updateOrCreatePackage(None, None, data, create_if_missing)
                elif len(packages) == 0:
                    if create_if_missing:
                        if package_name:
                            print(f'Creating new package {package_name}')
                            PACKAGE_MANAGER.createPackage(TYPE_ARTIFACT, package_name, update_data)
                        else:
                            exit_code = 2
                            print('ERROR: no name provided, the package cannot be created')
                    else:
                        print('No matching package, therefore no update has been performed.')
                elif len(packages) > 1:
                    print('Too many matching packages, therefore no update has been performed.')
                else:
                    package = packages[0]
                    try:
                        updater = ObjectMatcher(update_data)
                        package.updateWith(updater)
                    except Exception as e:
                        exit_code = 2
                        print('ERROR: while updating %s : %s' % (package, e))
            else:
                usage(2, 'ERROR: unknown command "%s"' % cmd)
        elif (target == TARGET_DOCKER):
            IMAGE_MANAGER = ImageManager(Path(root_directory, 'docker'), PACKAGE_MANAGER)
            images = None
            adv = ''
            cmd_ok = False
            if (cmd in ['ls', 'list']):
                cmd_ok = True
                images = IMAGE_MANAGER.listImages(CHANGES, touched)
                image_errors = IMAGE_MANAGER.errors()
                banner_message = 'Listing images'
                if (CHANGES):
                    banner_message += ' within %s' % CHANGES
                    if (touched):
                        banner_message += ' including modified'
                if (match_expression.hasCriteria):
                    banner_message += ' matching criteria %s' % match_expression
                    images = list(filter(lambda i: i.match(match_expression), images))
                if show_errors:
                    if len(image_errors) > 0:
                        exit_code = 21
                        print_error(f'Found {counted(image_errors, "error")} in images:')
                        print_error(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in image_errors.items())))
                    else:
                        print_success('Found no error in images')
                if (args):
                    if (len(args) > 1):
                        usage(2, 'ERROR: only one image name should be specified')
                    image_name = args[0]
                    banner_message += ' named "%s"' % image_name
                    images = list(filter(lambda p: p.name.startswith(image_name), images))
                    images.sort(key=lambda p: p.name)
                print(banner_message)
                if len(images) > 0 and not only_errors:
                    for img in images:
                        c = IMAGE_MANAGER.countImagesWithSameRepo(img)
                        if c > 1:
                            print(f'* {str(img)} (repo shared in {c} images)')
                        else:
                            print(f'* {str(img)}')
                print('Found %d %simages (%s)' % (len(images), adv, counted(image_errors, 'error')))
                command_logger.info('\n'.join(i.name for i in images))
            elif (cmd in ['check', 'chk']):
                cmd_ok = True
                images = IMAGE_MANAGER.listImages(CHANGES, touched)
                banner_message = 'Checking images for E2E-121 compliance'
                if (CHANGES):
                    banner_message += f' within {CHANGES}' 
                    if (touched):
                        banner_message += ' including modified'
                print(banner_message)
                logger = logging.getLogger()
                logger.setLevel(logging.CRITICAL)
                countValid = 0
                countError = 0
                countSkipped = 0
                countIgnored = 0
                for img in images:
                    valid, message = validateE2E(img, logger)
                    if not valid:
                        print(f'{"OK   " if valid else "ERROR"}: {message}')
                        exit_code = 22
                        countError += 1
                    elif valid == 'ignore':
                        countIgnored += 1
                    elif valid == 'skip':
                        countSkipped += 1
                    else:
                        countValid += 1
                            
                print(f'...done {countValid} valid, {counted(countError, "error")}, {countSkipped} skipped, {countIgnored} ignored')
            elif (cmd in ['imp', 'impacted']):
                cmd_ok = True
                adv = 'impacted '
                packages = PACKAGE_MANAGER.listPackages(CHANGES, touched)
                print('Packages:')
                if (len(packages) > 0):
                    print(' * %s' % ('\n * ').join((str(p) for p in packages)))
                print('Found %s' % counted(packages, 'modified package'))
                images = IMAGE_MANAGER.listImages(CHANGES, touched, packages)
                image_errors = IMAGE_MANAGER.errors()
                print('Images:')
                if (len(images) > 0):
                    print(' * %s' % ('\n * ').join((str(s) for s in images)))
                print('Found %d images (%s)' % (len(images), counted(image_errors, 'error')))
            elif (cmd == COMMAND_INSPECT or cmd == COMMAND_UPDATE):
                cmd_ok = True
                packages = PACKAGE_MANAGER.listPackages(CHANGES, touched)
                images = IMAGE_MANAGER.listImages(CHANGES, touched, packages)
                image_errors = IMAGE_MANAGER.errors()
                banner_message = f'Inspecting images (among {len(images)})'
                if (CHANGES):
                    banner_message += ' within %s' % CHANGES
                    if (touched):
                        banner_message += ' including modified'
                if (match_expression.hasCriteria):
                    banner_message += ' matching criteria %s' % match_expression
                    images = list(filter(lambda i: i.match(match_expression), images))
                if show_errors:
                    if len(image_errors) > 0:
                        exit_code = 21
                        print_error(f'Found {counted(image_errors, "error")} in images:')
                        print_error(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in image_errors.items())))
                    else:
                        print('Found no error in images')
                if (args):
                    image_names = args
                    banner_message += ' named "%s"' % image_names
                    images = list(filter(lambda p: p.name in image_names, images))
                all_data = []
                for img in images:
                    inspect_ok, inspect_data = img.inspect(None, force_pull)
                    inspect_digest = inspect_data['digest'] if inspect_ok else None
                    if (inspect_ok):
                        all_data.append(inspect_data)
                    img_pkg = PACKAGE_MANAGER.getPackage(img.name)
                    do_script = False
                    if (img_pkg is None):
                        if (inspect_ok):
                            do_script = bool(execute_script)
                            print(f'{img.name} : no package, registry Digest is "{inspect_digest}"')
                        else:
                            print(f'{img.name} : no package, and cannot inspect Image in registry')
                    elif (not inspect_ok):
                        print(f'{img.name} : package Digest is "{img_pkg.hash}", cannot inspect Image in registry')
                    else:
                        if (img_pkg.hash == inspect_digest):
                            # print(f'{img.name} : same Digest "{inspect_digest}"')
                            pass
                        else:
                            do_script = bool(execute_script)
                            print(f'{img.name} : different Digest, package is "{img_pkg.hash}" and Image in registry is "{inspect_digest}"')
                    if (inspect_ok):
                        if (cmd == COMMAND_UPDATE):
                            PACKAGE_MANAGER.updateOrCreatePackage(TYPE_IMAGE, img.name, inspect_data, True)
                        if (do_script):
                            try:
                                tag_split = img.tag.index('-')
                                tag_info = img.tag[tag_split + 1:]
                            except Exception:
                                tag_info = ''
                            params = sanitizeArgument([
                                img.name,
                                inspect_data['digest'],
                                inspect_data['buildDate'],
                                img.product,
                                img.asset,
                                img.version,
                                tag_info,
                                img.getProperty('platform', ''),
                                img.env,
                                json.dumps(inspect_data['labels'], ensure_ascii=False)
                            ])
                            for script in execute_script.split(','):
                                try:
                                    iter_process = subprocess.run([script, *params], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
                                    if (iter_process.returncode != 0):
                                        print(' %s' % iter_process.stdout, iter_process.returncode)
                                    else:
                                        print(iter_process.stdout)
                                except Exception as e:
                                    print(f'Cannot execute script "{script}" on Image {img.name} : {e}')
                if (len(all_data) > 0):
                    all_data.sort(key=lambda e: e['name'] if 'name' in e else '')
                    if (cmd == COMMAND_UPDATE):
                        try:
                            with open(ALL_IMAGES_FILE, mode='w+') as data_file:
                                json.dump(all_data, data_file, indent=2, ensure_ascii=False)
                            REPO.index.add(ALL_IMAGES_FILE)
                        except Exception:
                            print(f'Cannot update all images data file "{ALL_IMAGES_FILE}"')
                    else:
                        print(json.dumps(all_data, indent=2, ensure_ascii=False))
            elif cmd in [COMMAND_BUILD]:
                cmd_ok = True
                packages = PACKAGE_MANAGER.listPackages(CHANGES, touched)
                images = IMAGE_MANAGER.listImages(CHANGES, touched, packages)
                image_errors = IMAGE_MANAGER.errors()
                banner_message = f'Building images (among {len(images)})'
                if CHANGES:
                    banner_message += ' within %s' % CHANGES
                    if touched:
                        banner_message += ' including modified'
                if match_expression.hasCriteria:
                    banner_message += ' matching criteria %s' % match_expression
                    images = list(filter(lambda i: i.match(match_expression), images))
                if show_errors:
                    if len(image_errors) > 0:
                        exit_code = 21
                        print_error(f'Found {counted(image_errors, "error")} in images:')
                        print_error(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in image_errors.items())))
                    else:
                        print_success('Found no error in images')
                if args:
                    if len(args) > 1:
                        usage(2, 'ERROR: only one image name should be specified')
                    image_name = args[0]
                    banner_message += ' named "%s"' % image_name
                    images = list(filter(lambda p: p.name.startswith(image_name), images))
                    images.sort(key=lambda p: p.name)
                else:
                    image_name = None
                banner_message += ' for %d changed packages' % len(packages)
                print(banner_message)
                if len(images) == 0:
                    image_error = IMAGE_MANAGER.errorOnImage(image_name) if not image_name is None else None
                    if image_error is None:
                        print_warning('No matching image found')
                    else:
                        print_warning(f' Warning: {image_error.message}')
                        print_warning(f' This image in "{image_error.imageFile}" has been ignored.')
                build_ok_count = 0
                build_fail_count = 0
                build_error_count = 0
                all_results = list()
                for img in images:
                    try:
                        build_result = img.build(dry_run=dry_run)
                        if isinstance(build_result, BuildResult):
                            all_results.append(build_result)
                            logs = build_result.logs
                            if len(logs) > 0:
                                print(' # %s' % ('\n # ').join(logs))
                            if build_result.status == BuildStatus.PASS:
                                build_ok_count += 1
                                command_logger.info(img.name)
                            else:
                                build_fail_count += 1
                        elif build_result:
                            build_ok_count += 1
                            command_logger.info(img.name)
                        else:
                            build_fail_count += 1
                    except Exception as e:
                        build_error_count += 1
                        # print('Error building %s : %s\n%s' % (img, e, traceback.format_exc()))
                        print_error(f' Error building {img} : {e}')
                print('Builds: %s, %s, %s' % (counted(build_ok_count, 'pass'), counted(build_fail_count, 'fail'), counted(build_error_count, 'error')))
                if build_fail_count > 0:
                    exit_code += 100
                if build_error_count > 0:
                    exit_code += 1000
                if build_ok_count > 0:
                    print_success('Successful builds:')
                    for r in all_results:
                        if r.status == BuildStatus.PASS:
                            print_success(f'* {r.image}')
                if exit_code > 0:
                    if build_fail_count + build_error_count > 0:
                        print_error('Failed builds:')
                        for r in all_results:
                            if r.status != BuildStatus.PASS:
                                print_error(f'* {r.image}')
                    if len(image_errors) > 0:
                        exit_code = 21
                        print_error(f'Image errors:')
                        print_error(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in image_errors.items())))
            if not cmd_ok:
                usage(2, 'ERROR: unknown command "%s" for docker' % cmd)
        elif (target == TARGET_CHANGE):
            IMAGE_MANAGER = ImageManager(Path(root_directory, 'docker'), PACKAGE_MANAGER)
            changed_packages = set()
            changed_images = set()
            changed_files = set()
            for staged_files in REPO.index.diff('HEAD'):
                changed_path = staged_files.a_path
                exact_package = PACKAGE_MANAGER.findPackage(lambda p: p.gitPath == changed_path)
                if exact_package:
                    changed_packages.add(exact_package)
                else:
                    exact_image = IMAGE_MANAGER.findImage(lambda i: i.gitPath == changed_path)
                    if exact_image:
                        changed_images.add(exact_image)
                    else:
                        impacted_images = IMAGE_MANAGER.findImages(lambda i: changed_path.startswith(i.gitFolder))
                        if impacted_images:
                            changed_images.update(impacted_images)
                        else:
                            changed_files.add(changed_path)
            cmd_ok = False
            if cmd in [COMMAND_LIST, COMMAND_LIST_SHORT]:
                cmd_ok = True
                error = False
                print(f'Staged changes: {counted(changed_packages, "package")}, {counted(changed_images, "image")}, {counted(changed_files, "file")}')
                if len(changed_packages) > 0:
                    print('Packages:')
                    for p in changed_packages:
                        pkg_status, pkg_message = p.inspect()
                        if not pkg_status:
                            print(f' * {p.name} [ERROR: {pkg_message}]')
                            error = True
                        else:
                            print(f' * {p.name}')
                if len(changed_images) > 0:
                    print('Images:')
                    print(' * %s' % ('\n * ').join(str(i) for i in changed_images))
                if len(changed_files) > 0:
                    print('Files:')
                    print(' * %s' % ('\n * ').join(str(f) for f in changed_files))
            elif cmd in ['commit']:
                cmd_ok = True
                print(f'Staged changes: {counted(changed_packages, "package")}, {counted(changed_images, "image")}, {counted(changed_files, "file")}')
                commit_message = ''
                commit_error_message = ''
                commit_error = False
                if len(changed_packages) > 0:
                    commit_message += 'pkgs '
                    commit_message += ','.join(p.name for p in changed_packages)
                    for p in changed_packages:
                        pkg_status, pkg_message = p.inspect()
                        if not pkg_status:
                            commit_error = True
                            if len(commit_error_message) > 0:
                                commit_error_message += ', '
                            commit_error_message += f'error on package {p.name}: {pkg_message}'
                if len(changed_images) > 0:
                    commit_message += 'imgs '
                    commit_message += ','.join(i.name[29:] for i in changed_images)
                if len(changed_files) > 0:
                    if commit_all:
                        commit_message += 'files '
                        commit_message += ','.join(str(f) for f in changed_files)
                    else:
                        commit_error = True
                        commit_error_message = f'ERROR: {len(changed_files)} unexpected changes on files: {",".join(changed_files)}'
                if commit_error:
                    print(commit_error_message)
                    print(f'Discarding changes on {commit_message}')
                    print('CHANGES ARE NOT COMMITTED !')
                    exit_code = 3
                elif commit_message:
                    commit_message = '[CD] changes on ' + commit_message
                    print(commit_message)
                    #REPO.remotes.origin.pull()
                    REPO.index.commit(commit_message)
                    print(f'Pushing committed changes to {REPO.remotes.origin.url}')
                    pushInfos = REPO.remotes.origin.push()
                    pushFail = any(pi.flags & PushInfo.ERROR for pi in pushInfos)
                    if pushFail:
                        print(f'PUSH FAILED on {REPO.remotes.origin.url}: {pushInfos[0].summary}')
                        exit_code = 4
                    else:
                        print(f'Push ok on {REPO.remotes.origin.url}: {pushInfos[0].summary}')
                else:
                    print('No change on packages or images, no commit required')
            else:
                usage(2, f'ERROR: unknown command "{cmd}" for target {TARGET_CHANGE}')
        elif (target == TARGET_ASSET):
            IMAGE_MANAGER = ImageManager(Path(root_directory, 'docker'), PACKAGE_MANAGER)
            timestamp = int(time.time())
            if (len(metrics_prefix) > 0 and metrics_prefix[-1] != '.'):
                metrics_prefix += '.'
            classification = dict()
            PACKAGE_MANAGER.listPackagesClassification(classification)
            IMAGE_MANAGER.listImagesClassification(classification)
            columns = ['PRODUCT', 'ASSET', 'PACKAGES', 'IMAGES']
            lines = list()
            if (cmd == 'html'):
                beginHtmlReportTable(lines, 'm', *columns)
            elif (cmd != 'metrics'):
                lines = beginCsvReportTable(lines, '|', *columns)
            for product in classification:
                for asset in classification[product]:
                    refs = classification[product][asset]
                    total_packages = 0
                    total_images = 0
                    for r in refs:
                        if (isinstance(r, Image)):
                            total_images += 1
                        else:
                            total_packages += 1
                    if (cmd == 'html'):
                        addHtmlReportTableData(lines, product, asset, total_packages, total_images)
                    elif (cmd == 'metrics'):
                        print(f"{metrics_prefix}{product}.{asset}.packages {total_packages} {timestamp}")
                        print(f"{metrics_prefix}{product}.{asset}.images {total_images} {timestamp}")
                    else:
                        lines = addCsvReportTableData(lines, '|', product, asset, total_packages, total_images)
            if (cmd == 'html'):
                lines = endHtmlReportTable(lines)
                print('\n'.join(lines))
            elif (cmd != 'metrics'):
                lines = endCsvReportTable(lines, '|')
                print('\n'.join(lines))
        elif target == TARGET_CHART:
            IMAGE_MANAGER = ImageManager(Path(root_directory, 'docker'), PACKAGE_MANAGER)
            CHART_MANAGER = ChartManager(Path(root_directory, 'k8s'), PACKAGE_MANAGER, IMAGE_MANAGER)
            if cmd in [COMMAND_LIST, COMMAND_LIST_SHORT]:
                cmd_ok = True
                charts = CHART_MANAGER.listCharts(CHANGES, touched)
                chart_errors = CHART_MANAGER.errors()
                banner_message = 'Listing charts'
                if (CHANGES):
                    banner_message += ' within %s' % CHANGES
                    if (touched):
                        banner_message += ' including modified'
                if (match_expression.hasCriteria):
                    banner_message += ' matching criteria %s' % match_expression
                    charts = list(filter(lambda i: i.match(match_expression), charts))
                if show_errors:
                    if len(chart_errors) > 0:
                        exit_code = 21
                        print_error(f'Found {counted(chart_errors, "error")} in images:')
                        print_error(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in chart_errors.items())))
                    else:
                        print('Found no error in charts')
                if (args):
                    if (len(args) > 1):
                        usage(2, 'ERROR: only one chart name should be specified')
                    chart_name = args[0]
                    banner_message += ' named "%s"' % chart_name
                    charts = list(filter(lambda p: p.name.startswith(chart_name), charts))
                    charts.sort(key=lambda p: p.name)
                print(banner_message)
                if len(charts) > 0:
                    for chart in charts:
                        print(f'* {str(chart)}')
                print(f'Found {counted(charts, "chart")} ({counted(chart_errors, "error")})')
                command_logger.info('\n'.join(i.name for i in charts))
            elif cmd in [COMMAND_BUILD]:
                cmd_ok = True
                charts = CHART_MANAGER.listCharts(CHANGES, touched)
                chart_errors = CHART_MANAGER.errors()
                banner_message = f'Building charts (among {len(charts)})'
                if (CHANGES):
                    banner_message += ' within %s' % CHANGES
                    if (touched):
                        banner_message += ' including modified'
                if (match_expression.hasCriteria):
                    banner_message += ' matching criteria %s' % match_expression
                    charts = list(filter(lambda i: i.match(match_expression), charts))
                if show_errors:
                    if len(chart_errors) > 0:
                        exit_code = 21
                        print_error(f'Found {counted(chart_errors, "error")} in images:')
                        print_error(' * %s' % ('\n * ').join(('%s : %s' % (str(f), str(e)) for (f, e) in chart_errors.items())))
                    else:
                        print('Found no error in charts')
                if (args):
                    if (len(args) > 1):
                        usage(2, 'ERROR: only one chart name should be specified')
                    chart_name = args[0]
                    banner_message += ' named "%s"' % chart_name
                    charts = list(filter(lambda p: p.name.startswith(chart_name), charts))
                    charts.sort(key=lambda p: p.name)
                else:
                    chart_name = None
                print(banner_message)
                if len(charts) == 0:
                    chart_error = IMAGE_MANAGER.errorOnImage(chart_name) if not chart_name is None else None
                    if chart_error is None:
                        print('No matching chart found')
                    else:
                        print(f' Warning: {chart_error.message}')
                        print(f' This chart in "{chart_error.imageFile}" has been ignored.')
                build_ok_count = 0
                build_fail_count = 0
                build_error_count = 0
                all_results = list()
                for chart in charts:
                    try:
                        build_result = chart.build(dry_run=dry_run)
                        if isinstance(build_result, BuildResult):
                            all_results.append(build_result)
                            logs = build_result.logs
                            if len(logs) > 0:
                                print(' # %s' % ('\n # ').join(logs))
                            if build_result.status == BuildStatus.PASS:
                                build_ok_count += 1
                                command_logger.info(f'{chart.name},{chart.version},{chart.product},{chart.product_version},{build_result.dist_directory}')
                            else:
                                build_fail_count += 1
                        elif build_result:
                            build_ok_count += 1
                            command_logger.info(f'{chart.name},,,,')
                        else:
                            build_fail_count += 1
                    except Exception as e:
                        build_error_count += 1
                        print('Error building %s : %s\n%s' % (chart.name, e, traceback.format_exc()))
                        #print(f' Error building {chart} : {e}')
                print('Builds: %s, %s, %s' % (counted(build_ok_count, 'pass'), counted(build_fail_count, 'fail'), counted(build_error_count, 'error')))
                if (build_fail_count > 0):
                    exit_code += 100
                if (build_error_count > 0):
                    exit_code += 1000
                if (exit_code > 0):
                    print('Failed builds:')
                    for r in all_results:
                        if (r.status != BuildStatus.PASS):
                            print(f'* {r.target}')
                if (build_ok_count > 0):
                    print('Successful builds:')
                    for r in all_results:
                        if (r.status == BuildStatus.PASS):
                            print(f'* {r.target}')
            else:
                usage(2, f'ERROR: unknown command "{cmd}" for target {TARGET_CHART}')
        else:
            usage(2, 'ERROR: target "%s" is not implemented yet' % target)
    return exit_code


if __name__ == '__main__':
    sys.exit(main())
