from enum import Enum
from datetime import datetime, timezone
import logging
import os
from pathlib import Path

logger = logging.getLogger()

from shadoker.shadoker_globals import sanitizeDirectoryName

class TestStatus(Enum):
    """Status of a test, as defined in JUnit."""
    SUCCEEDED = 0
    FAILED = 1
    SKIPPED = 2
    ERROR = 3

class TestResult:
    def __init__(self, target: str, directory: str, console: bool = False):
        self._target = target

        self._directory = Path(sanitizeDirectoryName(directory))
        if not self._directory.exists():
            os.makedirs(self._directory, 0o777, True)

        self._console = console
        self._timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        self._total = 0
        self._counters = {
            TestStatus.SUCCEEDED: 0,
            TestStatus.FAILED: 0,
            TestStatus.SKIPPED: 0,
            TestStatus.ERROR: 0
        }
        self._tests = []

    @property
    def target(self):
        return self._target

    @property
    def directory(self):
        return self._directory
    
    def addTest(self, name: str, message: str, status: TestStatus):
        self._tests.append((name, status, message, datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')))
        self._total += 1
        self._counters[status] += 1
        if self._console:
            print(f'{status.name} {name} {message}')

    def preserveNewlineAttribute(self, attr: str) -> str:
        return attr.replace('\n', '&#13;&#10;')

    def dump(self):
        testFileName = Path(self._directory, f'test-{sanitizeDirectoryName(self._target)}.xml')
        logger.debug(f"Writing test result file '{testFileName}'")
        with open(str(testFileName), mode='w+') as test_file:
            test_file.write('<?xml version="1.0" encoding="utf-8"?>\n')
            test_file.write(f'<testsuite name="{self._target.replace(".", "_")}" tests="{self._total}" errors="{self._counters[TestStatus.ERROR]}" failures="{self._counters[TestStatus.FAILED]}" skip="{self._counters[TestStatus.SKIPPED]}" timestamp="{self._timestamp}">\n')
            for name, status, message, timestamp in self._tests:
                if status == TestStatus.ERROR:
                    test_file.write(f'  <testcase name="{name}">\n')
                    test_file.write(f'    <error message="{self.preserveNewlineAttribute(message)}"/>\n')
                    test_file.write( '  </testcase>\n')
                elif status == TestStatus.SKIPPED:
                    test_file.write(f'  <testcase name="{name}">\n')
                    test_file.write(f'    <skipped/>\n')
                    test_file.write( '  </testcase>\n')
                elif status == TestStatus.FAILED:
                    test_file.write(f'  <testcase name="{name}">\n')
                    test_file.write(f'    <failure message="{self.preserveNewlineAttribute(message)}"/>\n')
                    test_file.write( '  </testcase>\n')
                else:
                    test_file.write(f'  <testcase name="{name}"/>\n')
            test_file.write('</testsuite>')