import gzip
import os
from pathlib import Path
import tarfile
import zipfile

def extract(archive: str, path: str = None) -> bool:
    """Extract the given archive file into the specified path.
       If file is missing a FileNotFoundError exception is raised.
       If file exists but is not an archive, no operation is performed and this method returns False.
       If output path is omitted, then archive file name without extenstion is used.
       If extraction was ok this method return True, in all other cases an Exception is raised"""
    if (isinstance(archive, Path)):
        archive = str(archive)
    if (isinstance(path, Path)):
        path = str(path)
    if (not Path(archive).exists()):
        raise FileNotFoundError(f'Missing file "{archive}"')
    archive_lower = archive.lower()
    if (archive_lower.endswith('.tar.gz')):
        if (not path):
            path = archive[:-7]
        try:
            with tarfile.open(archive) as tar:
                tar.extractall(path)
        except Exception as e:
            raise OSError(f'Cannot extract archive "{archive}" : {e}')
    elif (archive_lower.endswith('.tgz') or archive_lower.endswith('.tar')):
        if (not path):
            path = archive[:-4]
        try:
            with tarfile.open(archive) as tar:
                tar.extractall(path)
        except Exception as e:
            raise OSError(f'Cannot extract archive "{archive}" : {e}')
    elif (archive_lower.endswith('.gz')):
        if (not path):
            path = archive[:-3]
        try:
            with gzip.open(archive, 'rb') as f:
                file_content = f.read()
                with open(path, 'wb') as w:
                    w.write(file_content)
        except Exception as e:
            raise OSError(f'Cannot extract archive "{archive}" : {e}')
    elif (archive_lower.endswith('.zip')):
        if (not path):
            path = archive[:-4]
        try:
            with zipfile.ZipFile(archive) as zip:
                zip.extractall(path)
        except Exception as e:
            raise OSError(f'Cannot extract archive "{archive}" : {e}')
    else:
        return False
    return True