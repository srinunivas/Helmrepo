# External package imports
import logging
import os
import subprocess
from git import Repo
from pathlib import Path, PurePosixPath

from shadoker.item_status import Status
from shadoker.shadoker_globals import PATTERN_MANIFEST, PATTERN_MANIFEST_INDEX

logger = logging.getLogger()


class ManifestManager:
    def __init__(self, repo: Repo, directory: Path):
        self.__repo = repo
        self.__directory = directory.resolve()
        self.__manifests = set()
        self.__indexes = set()
        self.__manifest_status = dict()
        staged_files = [d.a_path for d in repo.index.diff('HEAD')]
        for sub_directory, dirs, files in os.walk(directory):
            for filename in files:
                if PATTERN_MANIFEST.match(filename):
                    manifest_file = str(PurePosixPath(Path(sub_directory, filename)))
                    status = Status.OK
                    if (manifest_file in repo.untracked_files):
                        status = Status.UNTRACKED
                    else:
                        status = Status.STAGED if manifest_file in staged_files else Status.OK
                    if PATTERN_MANIFEST_INDEX.match(filename):
                        self.__indexes.add(manifest_file)
                    else:
                        self.__manifests.add(manifest_file)
                    self.__manifest_status[manifest_file] = status

    @property
    def repo(self):
        return self.__repo

    @property
    def directory(self):
        return self.__directory

    def listManifests(self, change_set=None, touched: bool = False, staged: bool = False):
        if (change_set or touched):
            return list(filter(lambda m: self.manifestBelongsTo(m, change_set, touched, staged), self.__manifests))
        else:
            return list(self.__manifests)

    def listIndexes(self, change_set=None, touched: bool = False, staged: bool = False):
        if (change_set or touched):
            return list(filter(lambda m: self.manifestBelongsTo(m, change_set, touched, staged), self.__indexes))
        else:
            return list(self.__indexes)

    def updateManifests(self, change_set=None, touched: bool = False, staged: bool = False):
        from build_result import BuildResult
        build_options = ['--no-color', '--generate-metadata']
        build_ok_count = 0
        build_fail_count = 0
        build_error_count = 0
        result = BuildResult('MANIFESTS', console=True)
        try:
            changed_manifests = self.listManifests(change_set, touched, staged)
            # Step 1: process all manifests at once
            if len(changed_manifests) > 0:
                result.logMessage(f'Building manifest(s) {changed_manifests}')
                build_commands = ['docker', 'run', '--rm', '-v', f'{os.getcwd()}:/shadoker', '-w', '/shadoker', 'jenkins-deploy.fircosoft.net/shadoker/manifesto']
                build_commands += build_options
                build_commands += changed_manifests
                result.logMessage(f' Executing {build_commands}')
                build_process = subprocess.run(build_commands, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
                if (build_process.returncode != 0):
                    build_fail_count += 1
                    result.logError(' %s' % build_process.stdout, build_process.returncode)
                else:
                    build_ok_count += 1
                    result.logMessage(' %s' % build_process.stdout)
        except Exception as ex:
            build_error_count += 1
            result.logError(f' Exception {ex}')
        return result

    def manifestBelongsTo(self, manifest, change_set, touched, staged) -> bool:
        """Is the given manifest file is part of a given ChangeSet ? This method checks package definition file status."""
        status = self.__manifest_status[manifest]
        if (staged and status == Status.STAGED):
            return True
        if (change_set):
            if (change_set.isChangedFile(manifest)):
                return True
            if (touched and (status == Status.UNTRACKED or change_set.isTouchedFile(manifest))):
                return True
            return False
        return True
