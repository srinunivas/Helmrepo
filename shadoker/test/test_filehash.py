import logging, os, unittest
from pathlib import Path

from shadoker.shadoker_globals import checkFileHash


class TestCheckFileHash(unittest.TestCase):
    def setup(self):
        """Switch directory to this test folder."""
        self.PWD = os.getcwd()
        os.chdir(os.path.dirname(os.path.abspath(__file__)))

    def teardown(self):
        """Switch back directory to initial value."""
        os.chdir(self.PWD)

    def test_checkFileHashErrors(self):
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        assert(checkFileHash('NOT_A_VALID_FILE', 'e922af6015f455b986181dd61001e4fa') < 0)
        assert(checkFileHash('test_archive_A.tar', 'NOT_A_VALID_HASH') < 0)
        assert(checkFileHash('test_archive_A.tar', None) < 0)
        assert(checkFileHash(None, 'e922af6015f455b986181dd61001e4fa') < 0)
        assert(checkFileHash('test_archive_A.tar', 'e922af6015f455b986181dd61001e4f') < 0) # Unknown hash format

    def test_Path(self):
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        assert(checkFileHash(Path('test_archive_A.tar'), 'sha1:1ed9ed485434bf54e3ef44d0881fbc61d5230dc3') == 0)

    def test_checkFileHashEqual(self):
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        assert(checkFileHash('test_archive_A.tar', 'e922af6015f455b986181dd61001e4fa') == 0)
        assert(checkFileHash('test_archive_A.tar', 'e922af6015f455b986181dd61001e4fa', None) == 0)
        assert(checkFileHash('test_archive_A.tar', 'md5:e922af6015f455b986181dd61001e4fa') == 0)
        assert(checkFileHash('test_archive_A.tar', '1ed9ed485434bf54e3ef44d0881fbc61d5230dc3') == 0)
        assert(checkFileHash('test_archive_A.tar', '1ED9ED485434BF54E3EF44D0881FBC61D5230DC3') == 0) # Upper case is ok
        assert(checkFileHash('test_archive_A.tar', 'sha1:1ed9ed485434bf54e3ef44d0881fbc61d5230dc3') == 0)
        assert(checkFileHash('test_archive_A.tar', 'sha-1:1ed9ed485434bf54e3ef44d0881fbc61d5230dc3') == 0)
        assert(checkFileHash('test_archive_A.tar', '4aeb41084c7acf99ce4746350bacc3118191769777f55f6bffc1782b8f183cc0') == 0)
        assert(checkFileHash('test_archive_A.tar', 'sha256:4aeb41084c7acf99ce4746350bacc3118191769777f55f6bffc1782b8f183cc0') == 0)
        assert(checkFileHash('test_archive_A.tar', 'sha-256:4aeb41084c7acf99ce4746350bacc3118191769777f55f6bffc1782b8f183cc0') == 0)
        assert(checkFileHash('test_archive_A.tar', 'SHA256:4AEB41084C7ACF99CE4746350BACC3118191769777F55F6BFFC1782B8F183CC0') == 0) # Upper case is ok

    def test_checkFileHashDiff(self):
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        assert(checkFileHash('test_archive_A.tar', 'md5:abcdef1234567890abcdef1234567890') > 0) # wrong MD5 hash
        assert(checkFileHash('test_archive_A.tar', 'sha1:abcdef0123456789abcdef123456789abcdef123') > 0) # wrong SHA-1 hash
        assert(checkFileHash('test_archive_A.tar', 'sha256:aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000') > 0) # wrong SHA-256 hash
    
    def test_checkFileHashWithLogger(self):
        logger = logging.getLogger()
        assert(checkFileHash('test_archive_A.tar', 'e922af6015f455b986181dd61001e4fa', logger) == 0)
        with self.assertLogs(logger, level = 'INFO') as cm:
            assert(checkFileHash('test_archive_A.tar', 'e922af6015f455b986181dd61001e4fb', logger) > 0)
            self.assertEqual(cm.output, ['INFO:root:Digest of file "test_archive_A.tar" is "e922af6015f455b986181dd61001e4fa" but not "e922af6015f455b986181dd61001e4fb" as expected.'])
        with self.assertLogs(logger, level = 'WARN') as cm:
            assert(checkFileHash('test_archive_A.tar', 'e922af6015f455b986181dd61001e4f', logger) < 0)
            self.assertEqual(cm.output, ['WARNING:root:Cannot determine has algorithm for "e922af6015f455b986181dd61001e4f".'])

