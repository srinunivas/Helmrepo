import json
from shadoker.object_matcher import ObjectMatcher


def test_creation():
    o = ObjectMatcher()
    assert(o)


def test_string():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a', 'Hello')
    test_object = {'b': 'Hello'}
    assert(not match_expression.match(test_object))
    test_object = {'a': 'Bye'}
    assert(not match_expression.match(test_object))
    test_object = {'a': 'Hello'}
    assert(match_expression.match(test_object))


def test_numerical():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a', 123)
    test_object = {'b': 123}
    assert(not match_expression.match(test_object))
    test_object = {'a': 456}
    assert(not match_expression.match(test_object))
    test_object = {'a': 123}
    assert(match_expression.match(test_object))


def test_boolean():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a', False)
    test_object = {'b': False}
    assert(not match_expression.match(test_object))
    test_object = {'a': True}
    assert(not match_expression.match(test_object))
    test_object = {'a': False}
    assert(match_expression.match(test_object))
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a', True)
    test_object = {'b': True}
    assert(not match_expression.match(test_object))
    test_object = {'a': False}
    assert(not match_expression.match(test_object))
    test_object = {'a': True}
    assert(match_expression.match(test_object))


def test_nested():
    match_expression = ObjectMatcher()
    match_expression.addCriteria({'a': {'x': 'Hello'}})
    test_object = {'b': 'Hello'}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': 'Bye'}}
    assert(not match_expression.match(test_object))
    test_object = {'z': 0, 'a': {'x': 'Hello'}}
    assert(match_expression.match(test_object))


def test_nested_syntax2():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a', {'x': {'y': 'Hello'}})
    test_object = {'b': 'Hello'}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': 'Bye'}}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': {'y': 'Bye'}}}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': {'y': {'z': 'Hello'}}}}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': {'y': 'Hello'}}}
    assert(match_expression.match(test_object))


def test_nested_dot():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a.x.y', 'Hello')
    test_object = {'b': 'Hello'}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': 'Bye'}}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': {'y': 'Bye'}}}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': {'y': {'z': 'Hello'}}}}
    assert(not match_expression.match(test_object))
    test_object = {'a': {'x': {'y': 'Hello'}}}
    assert(match_expression.match(test_object))


def test_values():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a', 'Hello')
    match_expression.addCriteria('b', 'World')
    test_object = {'b': 'Hello'}
    assert(not match_expression.match(test_object))
    test_object = {'a': 'Hello'}
    assert(not match_expression.match(test_object))
    test_object = {'a': 'Hello', 'b': 'World'}
    assert(match_expression.match(test_object))


def test_regex():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a', '/.*Hello.*/')
    test_object = {'b': 'Hello'}
    assert(not match_expression.match(test_object))
    test_object = {'a': 'Bye'}
    assert(not match_expression.match(test_object))
    test_object = {'a': 'This is a sentence with "Hello" word'}
    assert(match_expression.match(test_object))


def test_not_value():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a!', 'Hello')
    test_object = {'b': 'Hello'}
    assert(match_expression.match(test_object))
    test_object = {'a': 'Bye'}
    assert(match_expression.match(test_object))
    test_object = {'a': 'Hello'}
    assert(not match_expression.match(test_object))


def test_not_regex():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a!', '/.*Hello.*/')
    test_object = {'b': 'Hello'}
    assert(match_expression.match(test_object))
    test_object = {'a': 'Bye'}
    assert(match_expression.match(test_object))
    test_object = {'a': 'This is a sentence with "Hello" word'}
    assert(not match_expression.match(test_object))


def test_everything():
    match_expression = ObjectMatcher()
    match_expression.addCriteria('a!', '/.*Hello.*/')
    match_expression.addCriteria('b', {'x': '/.*WORLD.*/i'})
    match_expression.addCriteria('c', True)
    match_expression.addCriteria({'d': {'r': 44}})
    match_expression.addCriteria('d.y!', '/.*IGNORE.*/')
    match_expression.addCriteria('e!', True)
    test_object = {
        'a': 'Really',
        'b': {
            'x': 'This is the World'
        },
        'c': True,
        'd': {
            'y': 'must PROCEED',
            'r': 44
        }
    }
    assert(match_expression.match(test_object))


def test_update():
    base = json.loads('{"a.b": "hello"}')
    change = json.loads('{"a.b": "bye"}')
    updater = ObjectMatcher(change)
    modified, count = updater.update(base)
    assert(modified['a.b'] == 'bye')
    assert(count == 1)
