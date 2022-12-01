from pathlib import PurePosixPath
from git import Repo

class ChangeSet:
    def __init__(self, repo: Repo, start, end):
        self.__repo = repo
        self.__start = start or '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
        self.__end = end or 'HEAD'
        self.__changes = set()
        self.__touched = set()
        self.__diff = repo.git.diff('--name-only', self.__start, self.__end) if repo else ''
        if repo:
            self.__changes.update(self.__diff.split())
            self.__touched.update(item.a_path for item in repo.index.diff(None))
        #self.__diff = repo.commit(end).diff(repo.commit(start))
        #for x in self.__diff:
        #    if x.a_blob.path not in self.__changes:
        #        self.__changes.add(x.a_blob.path)
        #    if x.b_blob is not None and x.b_blob.path not in self.__changes:
        #        self.__changes.add(x.b_blob.path)

    @property
    def repo(self):
        return self.__repo
    
    @property
    def start(self):
        return self.__start

    @property
    def end(self):
        return self.__end

    def isLimited(self):
        """Is this ChangeSet actually reflecting a limited time range."""
        if (self.__start != '4b825dc642cb6eb9a060e54bf8d69288fbee4904'):
            return True
        if (self.__end != 'HEAD'):
            return True
        return False

    @property
    def allChangedFiles(self):
        return self.__changes
    
    def allTouchedFiles(self):
        return self.__touched

    def isChangedFile(self, file):
        return str(PurePosixPath(file)) in self.__changes

    def isTouchedFile(self, file):
        return str(PurePosixPath(file)) in self.__touched

    @staticmethod
    def _isFileInFolder(file: str, folder: str, excludingSubFolder = None, excludingFilePattern = None):
        if file.startswith(folder):
            if excludingSubFolder or excludingFilePattern:
                excluded = False
                fileRelativePath = file[len(folder):]
                if excludingSubFolder:
                    excluded = fileRelativePath.startswith(excludingSubFolder)
                if not excluded and excludingFilePattern:
                    excluded = excludingFilePattern.match(fileRelativePath)
                if not excluded:
                    return True
            else:
                return True
        return False

    def isChangedFolder(self, folder, excludingSubFolder = None, excludingFilePattern = None):
        folder = str(PurePosixPath(folder))
        if folder[-1] != '/':
            folder += '/'
        if isinstance(excludingSubFolder, str) and not excludingSubFolder[-1] == '/':
            excludingSubFolder += '/'
        for filePath in self.__changes:
            if ChangeSet._isFileInFolder(filePath, folder, excludingSubFolder, excludingFilePattern):
                return True
        return False

    def isTouchedFolder(self, folder, excludingSubFolder = None, excludingFilePattern = None):
        folder = str(PurePosixPath(folder))
        if folder[-1] != '/':
            folder += '/'
        if isinstance(excludingSubFolder, str) and not excludingSubFolder[-1] == '/':
            excludingSubFolder += '/'
        for filePath in self.__touched:
            if ChangeSet._isFileInFolder(filePath, folder, excludingSubFolder, excludingFilePattern):
                return True
        return False

    def changedFilesInFolder(self, folder):
        f = str(PurePosixPath(folder)) + '/'
        return { x for x in self.__changes if x.startswith(f) }

    def touchedFilesInFolder(self, folder):
        f = str(PurePosixPath(folder)) + '/'
        return { x for x in self.__touched if x.startswith(f) }

    def print(self):
        return 'Changes from %s to %s :\n * %s\nChanges: %d\nTouched files:\n * %s\nTouched: %d' % (self.__start, self.__end, ('\n * ').join(self.__changes), len(self.__changes), ('\n * ').join(self.__touched), len(self.__touched))

    def __str__(self):
        return 'changes from %s to %s' % (self.__start, self.__end)