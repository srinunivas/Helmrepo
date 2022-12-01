from shadoker.shadoker_globals import filterDict

def test_filter():
    a = {'x': 1, 'y': 22}
    b = filterDict(lambda k, v: not k == 'x', a)
    assert(isinstance(b, dict))
    assert(not 'x' in b)
    a['y'] = 222
    assert(b['y'] == 22)
