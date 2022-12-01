import re
from typing import Any, Tuple

# TODO: check if inheriting from dict or UserDict isn't better and using dict3 = {**dict1 , **dict2} to concatenate


class ObjectMatcher:
    def __init__(self, m: dict = None):
        self._matcher = m.copy() if (isinstance(m, dict)) else None

    def addCriteria(self, key_or_dict, value=None):
        if (not self._matcher):
            self._matcher = dict()
        if (isinstance(key_or_dict, dict)):
            if (value is not None):
                return (False, 'Cannot specify dictionary and value at the same time')
            for k in key_or_dict:
                r, m = self._add(k, key_or_dict[k])
                if (not r):
                    return (r, m)
        else:
            r, m = self._add(key_or_dict, value)
            if (not r):
                return (r, m)
        return (True, 'criteria successfully added')

    def getCriteria(self, key):
        if (not self._matcher):
            return None
        return self._matcher[key] if (key in self._matcher) else None

    @staticmethod
    def _merge(d: dict, k: str, v: Any):
        dot = k.find('.')
        if (dot >= 0):
            return ObjectMatcher._merge(d, k[:dot], {k[dot + 1:]: v})
        if (k in d):
            if (not isinstance(v, dict) or not isinstance(d[k], dict)):
                return (False, f'cannot redefine key "{k}"')
        if (isinstance(v, dict)):
            if (k not in d):
                d[k] = dict()
            for k2 in v:
                r, m = ObjectMatcher._merge(d[k], k2, v[k2])
                if (not r):
                    return (r, m)
            return (True, f'added key "{k}"')
        else:
            d[k] = ObjectMatcher._convert(v)
            return (True, f'added key "{k}"')

    def _add(self, k, v):
        return ObjectMatcher._merge(self._matcher, k, v)
        # if (k in self._matcher):
        #     return (False, 'duplicate key "%s"' % k)
        # self._matcher[k] = self._convert(v)
        # return (True, 'added key "%s"' % k)

    @staticmethod
    def _convert(value):
        if (isinstance(value, str) and len(value) > 0 and value[0] == '/' and (value[-1] == '/' or value.endswith('/i'))):
            if (value.endswith('/i')):
                return re.compile(value[1:-2], re.IGNORECASE)
            else:
                return re.compile(value[1:-1])
        else:
            return value

    def match(self, obj: object) -> bool:
        return ObjectMatcher._match(self._matcher, obj)

    @staticmethod
    def _match(a: dict, b: dict) -> bool:
        for key in a:
            valA = a[key]
            positive_condition = True
            if (key.endswith('!')):
                key = key[:-1]
                positive_condition = False
            if (key not in b):
                if (positive_condition):
                    return False
            else:
                valB = b[key]
                if (isinstance(valA, dict)):
                    if (positive_condition):
                        if (not isinstance(valB, dict)):
                            return False
                    else:
                        if (not isinstance(valB, dict)):
                            continue
                    deep_match = ObjectMatcher._match(valA, valB)
                    if (positive_condition):
                        if (not deep_match):
                            return False
                    else:
                        if (deep_match):
                            return False
                elif (ObjectMatcher.isPattern(valA)):
                    if (positive_condition):
                        if (not isinstance(valB, str)):
                            return False
                    else:
                        if (not isinstance(valB, str)):
                            continue
                    pattern_match = valA.match(valB)
                    if (positive_condition):
                        if (not pattern_match):
                            return False
                    else:
                        if (pattern_match):
                            return False
                else:
                    if (positive_condition):
                        if (valA != valB):
                            return False
                    else:
                        if (valA == valB):
                            return False
        return True

    def update(self, obj: dict) -> Tuple[dict, int]:
        """Updates or creates values recursively in given dictionary 'obj' from values in this ObjectMatcher instance"""
        return ObjectMatcher._update(obj, self._matcher)

    @staticmethod
    def _update(a: dict, b: dict) -> Tuple[dict, int]:
        """Updates or creates values recursively in dictionary 'a' with values from dictionary 'b'"""
        if (a is None):
            a = dict()
        elif (not isinstance(a, dict)):
            raise Exception('First parameter must be a dict')
        if (b is None):
            return (a, 0)
        elif (not isinstance(b, dict)):
            raise Exception('Second parameter must be a dict')
        changes = 0
        for key in b:
            if (key not in a):
                a[key] = b[key]
                changes += 1
            else:
                if (isinstance(a[key], dict) and isinstance(b[key], dict)):
                    a[key], inner_changes = ObjectMatcher._update(
                        a[key], b[key])
                    changes += inner_changes
                elif (a[key] != b[key]):
                    a[key] = b[key]
                    changes += 1
        return (a, changes)

    @property
    def hasCriteria(self):
        return self._matcher and len(self._matcher.items()) > 0

    @staticmethod
    def isPattern(p):
        return type(p).__name__.endswith('Pattern')

    def __str__(self):
        return '{%s}' % ','.join(('%s=%s' % (k, v.pattern if ObjectMatcher.isPattern(v) else v) for k, v in self._matcher.items()))
