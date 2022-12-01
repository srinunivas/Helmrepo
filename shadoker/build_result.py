import logging
from enum import Enum
from typing import Union
import warnings

logger = logging.getLogger()

class BuildStatus(Enum):
    """Status of a build."""
    BUILDING = -1
    PASS = 0
    FAIL = 1

class BuildResult:
    def __init__(self, target: Union['Image', 'Chart'], console: bool = False):
        self._target = target
        self._build_directory = None
        self._dist_directory = None
        self._status = BuildStatus.BUILDING
        self._exit_code = 0
        self._log = list()
        self._console = console

    @property
    def image(self):
        warnings.warn(
            '"image" is deprecated, use "target" instead',
            DeprecationWarning
        )
        return self._target

    @property
    def target(self):
        return self._target

    @property
    def build_directory(self):
        return self._build_directory
    
    @build_directory.setter
    def build_directory(self, value):
        if self._build_directory is None:
            self._build_directory = value
        else:
            raise Exception(f'Build directory for this result is already set')

    @property
    def dist_directory(self):
        return self._dist_directory
    
    @dist_directory.setter
    def dist_directory(self, value):
        if self._dist_directory is None:
            self._dist_directory = value
        else:
            raise Exception(f'Distribution directory for this result is already set')

    @property
    def status(self):
        return self._status

    @property
    def exitCode(self):
        return self._exit_code

    @property
    def logs(self):
        return tuple(self._log)

    def logMessage(self, msg: str):
        self._log.append(msg)
        if self._console:
            print(msg)

    def logError(self, msg: str, exit_code: int = 0):
        self._status = BuildStatus.FAIL
        self._log.append(msg)
        if self._console:
            print(msg)
        if (exit_code != 0):
            self._exit_code = exit_code
    
    def end(self):
        if (self._status == BuildStatus.BUILDING):
            self._status = BuildStatus.PASS

    def isFailed(self):
        return self._status == BuildStatus.FAIL
