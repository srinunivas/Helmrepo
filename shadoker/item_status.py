from enum import Enum


class Status(Enum):
    OK = 0
    TOUCHED = 1
    STAGED = 2
    UNTRACKED = 3