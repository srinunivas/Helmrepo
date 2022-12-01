from copy import deepcopy
from datetime import datetime
from pathlib import Path
from typing import Any, Optional, Tuple, Union, Dict
import hashlib, io, logging, os, platform, random, re, shutil, stat, urllib
from uuid import UUID

PACKAGE_INSTALLDIR = '_packages'
IMAGEINFO_DIR = '_imageInfo'
TYPE_IMAGE = 'image'
TYPE_ARTIFACT = 'artifact'
PATTERN_MANIFEST = re.compile(r'(?i)^[^/]*manifest\.(ya?ml|mjs)$')
PATTERN_MANIFEST_INDEX = re.compile(r'(?i)^[^/]*indexmanifest\.ya?ml$')
NOW = datetime.utcnow()
TIMESTAMP_NOW = NOW.timestamp()
TIMESTAMP_STR_NOW = NOW.strftime('%Y-%m-%dT%H:%M:%SZ')
DEPENDENCY_PROPERTY_KEY = 'deps'
RESERVED_IMAGE_PROPERTIES = [DEPENDENCY_PROPERTY_KEY, 'dependencies', 'autoBuild', 'autoPush', 'name', 'tags']

def nestValue(key: str, value: Any) -> Tuple[str, Any]:
    i = key.rfind('.')
    if (i >= 0):
        return nestValue(key[:i], {key[i + 1:]: value})
    return (key, value)


def filterDict(predicate: callable, dictionary: dict) -> dict:
    r = deepcopy(dictionary)
    for (key, value) in dictionary.items():
        if (not predicate(key, value)):
            del r[key]
    return r


def cast2bool(v: Any) -> bool:
    if (isinstance(v, bool)):
        return v
    elif (isinstance(v, str)):
        return v.lower() in ['true', '1', 'yes', 'y']
    else:
        return bool(v)


def getBoolProperty(object: dict, property_name: str, default: Optional[bool]) -> bool:
    if property_name in object:
        return cast2bool(object[property_name])
    elif default is None:
        raise Exception(f'Boolean propery "{property_name}" not found and no default value"')
    else:
        return default


def getArrayProperty(object: dict, property_name: str, default: Optional[Any]) -> list:
    if property_name in object:
        v = object[property_name]
        if isinstance(v, list):
            return v
        else:
            return [v]
    elif default is None:
        raise Exception(f'Array propery "{property_name}" not found and no default value"')
    else:
        if isinstance(default, list):
            return default
        else:
            return [default]


def deepupdate(a: dict, b: dict) -> None:
    for k in b:
        if k not in a:
            a[k] = deepcopy(b[k])
        else:
            if (isinstance(a[k], dict) and isinstance(b[k], dict)):
                deepupdate(a[k], b[k])
            else:
                a[k] = deepcopy(b[k])


def randomindex() -> str:
    i = random.randrange(9867542310)
    m = hashlib.md5()
    m.update(i.to_bytes(8, byteorder='big'))
    return m.hexdigest()[:10]


def sha256toUUIDurn(sha256: str) -> str:
    if sha256.startswith('sha256:'):
        sha256 = sha256[7:]
    m = hashlib.md5()
    m.update(str.encode(sha256))
    return UUID(m.hexdigest()).urn


def checkFileHash(file: Union[str, Path, io.BufferedIOBase], hash: str, logger: logging.Logger = None) -> int:
    """Checks that specified file matches the given digest hash value.
       Accepted hash algorithm are MD5, SHA-1 and SHA-256.
       Return value is a number which is:
       * zero is hash values correctly matches,
       * negative if file or hash parameters are invalid,
       * positive if computed hash differs from the specified value"""
    if (not file or not hash):
        return -1
    hash_parts = hash.split(':')
    hash_algo = None
    if (len(hash_parts) == 2):
        hash_algo = hash_parts[0].lower()
        if (hash_algo == 'md5'):
            hash_algo = hashlib.md5()
        elif (hash_algo == 'sha1' or hash_algo == 'sha-1'):
            hash_algo = hashlib.sha1()
        elif (hash_algo == 'sha256' or hash_algo == 'sha-256'):
            hash_algo = hashlib.sha256()
        else:
            if (isinstance(logger, logging.Logger)):
                logger.warning(f'Hash algorithm "{hash_algo}" is not valid for shadoker.')
            return -2
        hash = hash_parts[1].lower()
    elif (len(hash_parts) == 1):
        if (len(hash) == 32):
            hash_algo = hashlib.md5()
        elif (len(hash) == 40):
            hash_algo = hashlib.sha1()
        elif (len(hash) == 64):
            hash_algo = hashlib.sha256()
        else:
            if (isinstance(logger, logging.Logger)):
                logger.warning(f'Cannot determine has algorithm for "{hash}".')
            return -2
        hash = hash.lower()
    else:
        if (isinstance(logger, logging.Logger)):
            logger.warning(f'Cannot determine has algorithm for "{hash}".')
        return -2
    BLOCK_SIZE = 65536
    file_desc = f'file "{file}"' if (isinstance(file, str)) else 'stream'
    try:
        stream = open(file, 'rb') if (isinstance(file, str) or isinstance(file, Path)) else file
        with stream as f:
            fb = f.read(BLOCK_SIZE)
            while len(fb) > 0:
                hash_algo.update(fb)
                fb = f.read(BLOCK_SIZE)
        digest = hash_algo.hexdigest()
    except Exception as e:
        if (isinstance(logger, logging.Logger)):
            logger.info(f'Error while reading {file_desc}: {e}.')
        return -3
    if (digest == hash):
        return 0
    else:
        if (isinstance(logger, logging.Logger)):
            logger.info(f'Digest of {file_desc} is "{digest}" but not "{hash}" as expected.')
        return 1


def checkUri(uri: str, hash: Union[str, None]) -> Tuple[bool, str]:
    """Checks that specified URL exists and optionally matches the specified hash value.
       Accepted hash algorithm are MD5, SHA-1 and SHA-256.
       Return value is a tuple:
       * a boolean value which is true if the check is fine,
       * a message string with details on the check result"""
    try:
        status = False
        msg = ''
        req = urllib.request.Request(url=uri, method='GET' if hash else 'HEAD')
        with urllib.request.urlopen(req) as f:
            if (hash):
                if (checkFileHash(f, hash) == 0):
                    status = True
                    msg = f'OK {uri} ({f.status}/hash={hash})'
                else:
                    msg = f'DIFFERENT HASH {uri} ({f.status}/hash={hash})'
            else:
                status = True
                msg = f'OK {uri} ({f.status})'
        return (status, msg)
    except urllib.error.HTTPError as http_error:
        return (False, f'{http_error}')
    except Exception as error:
        return (False, f'{error}')


def on_rm_error(func, path, exc_info):
    os.chmod(path, stat.S_IWRITE)
    try:
        os.unlink(path)
    except Exception:
        pass


def forcedrmdir(dir: str):
    if (os.path.exists(dir)):
        shutil.rmtree(dir, onerror=on_rm_error)


def sanitizeDirectoryName(path: str):
    if (isinstance(path, str)):
        return path.replace('/', '_').replace('\\', '_').replace(':', '@')
    else:
        return path


def sanitizeEnvironmentVariable(var: str):
    if (isinstance(var, str)):
        return var.upper().replace('.', '_').replace('-', '').replace(' ', '')
    else:
        return var


def sanitizeTagToken(var: str) -> str:
    if not isinstance(var, str):
        var = str(var)
    return var.replace('/', '_').replace('-', '_').replace(' ', '_')


def fromDockerDatetime(d: str) -> str:
    i = d.index('.')
    if (i >= 0):
        d = d[:i+4] + d[-1]
    return d


def sanitizeArgument(arg: str) -> str:
    if isinstance(arg, list):
        return list(map(sanitizeArgument, arg))
    if arg is None:
        return ''
    if isinstance(arg, str):
        if platform.system() != 'Windows':
            return arg
        else:
            # Escaping & \ < > ^ |
            return arg.replace('^', '^^').replace('&', '^&').replace('\\', '^\\').replace('<', '^<').replace('>', '^>').replace('|', '^|')
    return arg

c2k_pattern1 = re.compile(r'(.)([A-Z][a-z]+)')
c2k_pattern2 = re.compile(r'([a-z0-9])([A-Z])')
def camelToKebabCase(s: str) -> str:
    if (isinstance(s, str)):
        s = c2k_pattern1.sub(r'\1-\2', s)
        return c2k_pattern2.sub(r'\1-\2', s).lower()
    else:
        return s


def getValue(d: Dict, *keys) -> Any:
    if not isinstance(d, dict) and not isinstance(d, list):
        raise ValueError("First parameter must be a Dictionary or a list")
    if len(keys) == 0:
        raise ValueError("Second parameter missing")
    return __getValue(d, *keys)


def __getValue(d: Dict, *keys) -> Any:
    if len(keys) == 0:
        return d
    k = keys[0]
    if isinstance(d, dict):
        if k in d:
            return __getValue(d[k], *keys[1:])
    elif isinstance(d, list):
        if isinstance(k, int):
            if k < len(d):
                return __getValue(d[k], *keys[1:])
    return None


def getFirstMatch(d: Dict, k1, k2=None, k3=None, k4=None, default=None):
    """Returns the value of the first matching key in the given dictionary
    """
    if not isinstance(d, dict):
        raise Exception("STOP")
        # return default
    if k1 in d:
        return d[k1]
    if k2 in d:
        return d[k2]
    if k3 in d:
        return d[k3]
    if k4 in d:
        return d[k4]
    return default