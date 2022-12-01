import os
from pathlib import Path
import pytest
import re
import shutil
import unittest

from shadoker.archiver import extract

PWD = os.getcwd()
def setup_module(module):
    """Switch directory to this test folder, remove any previous temp folders."""
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    shutil.rmtree('TEST_TAR', True)
    shutil.rmtree('TEST_TGZ', True)
    shutil.rmtree('TEST_TARGZ', True)
    shutil.rmtree('TEST_ZIP', True)
    shutil.rmtree('TEST_GZ', True)
    shutil.rmtree('test_archive_A', True)
    shutil.rmtree('test_archive_B', True)
    shutil.rmtree('test_archive_C', True)

def teardown_module(module):
    """Remove all created temp folders and switch back directory to initial value."""
    shutil.rmtree('TEST_TAR', True)
    shutil.rmtree('TEST_TGZ', True)
    shutil.rmtree('TEST_TARGZ', True)
    shutil.rmtree('TEST_ZIP', True)
    shutil.rmtree('TEST_GZ', True)
    shutil.rmtree('test_archive_A', True)
    shutil.rmtree('test_archive_B', True)
    shutil.rmtree('test_archive_C', True)
    os.chdir(PWD)

def test_extract_valid_archives():
    assert(extract('test_archive_A.tar', 'TEST_TAR'))
    assert(Path('TEST_TAR/test_archive/a/b').exists())
    assert(extract('test_archive_B.tar.gz', 'TEST_TARGZ'))
    assert(Path('TEST_TARGZ/test_archive/a/b').exists())
    assert(extract('test_archive_BB.tgz', 'TEST_TGZ'))
    assert(Path('TEST_TGZ/test_archive/a/b').exists())
    assert(extract('test_archive_C.zip', 'TEST_ZIP'))
    assert(Path('TEST_ZIP/test_archive/a/b').exists())
    try:
        os.remove('test_large_text_file.txt')
    except:
        pass
    assert(extract('test_large_text_file.txt.gz'))
    assert(Path('test_large_text_file.txt').exists())
    try:
        os.remove('test_large_text_file.txt')
    except:
        pass

def test_extract_valid_archives_with_no_path():
    assert(extract('test_archive_A.tar'))
    assert(Path('test_archive_A/test_archive/a/b').exists())
    assert(extract('test_archive_B.tar.gz'))
    assert(Path('test_archive_B/test_archive/a/b').exists())
    assert(extract('test_archive_C.zip'))
    assert(Path('test_archive_C/test_archive/a/b').exists())

def test_extract_invalid_archives():
    with pytest.raises(OSError):
        assert(extract('test_archive_KO.tar', 'TEST_TAR'))
    with pytest.raises(OSError):
        assert(extract('test_archive_KO.tar.gz', 'TEST_TARGZ'))
    with pytest.raises(OSError):
        assert(extract('test_archive_KO.zip', 'TEST_ZIP'))

def test_extract_invalid_file():
    with pytest.raises(OSError):
        assert(extract('test_archive_KO.gz', 'TEST_GZ'))

def test_extract_non_archive():
    assert(False == extract(__file__, 'TEST_NON_ARCHIVE'))

def test_extract_missing_file():
    with pytest.raises(FileNotFoundError):
        extract('test_archive_MISSING.tar', 'TEST_TAR_MISSING')

def test_extract_missing_non_archive():
    with pytest.raises(FileNotFoundError):
        assert(False == extract('test_non_archive_MISSING', 'TEST_NON_ARCHIVE_MISSING'))