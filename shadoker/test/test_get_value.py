import pytest
from shadoker.shadoker_globals import getValue

def test_getValue():
    a = {'x': 1, 'y': 22}
    assert(getValue(a, 'x') == 1)
    assert(getValue(a, 'x', 'y') is None)
    assert(getValue(a, 'z') is None)
    with pytest.raises(ValueError):
        getValue(None)
    with pytest.raises(ValueError):
        getValue(a)
    with pytest.raises(ValueError):
        getValue(None, '')

def test_nested_getValue():
    a = {'x': 1, 'y': {'z': 22}}
    assert(getValue(a, 'y', 'z') == 22)
    assert(getValue(a, 'x', 'z') is None)

def test_nested_getValue():
    v1 = [{'y': {'z': 22}} , {'y': {'z': 33}}]
    assert(getValue(v1, 1, 'y', 'z') == 33)
    assert(getValue(v1, 3, 'y', 'z') is None)

    d1 = { 'x': [{'y': {'z': 22}}] }
    assert(getValue(d1, 'x', 0, 'y', 'z') == 22)
    assert(getValue(d1, 'x', 1, 'y', 'z') is None)
    assert(getValue(d1, 'x', 2, 'y', 'z') is None)

def test_dict_getValue():
    a = {'x': {'z': 22}}
    assert(isinstance(getValue(a, 'x'), dict))
