from shadoker.shadoker_globals import randomindex

def test_randomindex():
    a = randomindex()
    b = randomindex()
    assert(a != b)
