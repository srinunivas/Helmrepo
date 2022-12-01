import pytest, re

from shadoker.template_renderer import TemplateRenderer

def test_creation():
    tr1 = TemplateRenderer()
    assert(tr1)

def test_rendering():
    tr1 = TemplateRenderer()
    tr1.addProperty('a', 'xyz')
    s = tr1.renderString('This is a')
    assert(s == 'This is a')
    s = tr1.renderString('This is {{a}}')
    assert(s == 'This is xyz')
    with pytest.raises(NameError):
        s = tr1.renderString('This is {{b}}')

def test_rendering_more():
    tr1 = TemplateRenderer()
    tr1.addProperties({'not_a': '123', 'a': 'xyz'})
    s = tr1.renderString('This is a')
    assert(s == 'This is a')
    s = tr1.renderString('This is {{a}}')
    assert(s == 'This is xyz')
    with pytest.raises(NameError):
        s = tr1.renderString('This is {{b}}')

def test_rendering_array():
    tr1 = TemplateRenderer()
    tr1.addProperties({'a': '123', 'b': 'xyz'})
    s = tr1.renderStrings(['A', 'B-{{a}}', 'C-{{z}}'])
    assert(s == ['A', 'B-123'])
    with pytest.raises(NameError):
        s = tr1.renderStrings(['A', 'B-{{a}}', 'C-{{z}}'], True)

def test_rendering_nested_array():
    tr1 = TemplateRenderer()
    tr1.addProperties({'a': '123', 'b': [77, 'seventy-seven']})
    tr2 = TemplateRenderer(None, tr1)
    assert(tr2)
    tr2.addProperty('c', ['{{a}}-HELLO'])
    s = tr2.renderString('{{c}}') # rendering of an array into a string is not really useful
    assert(re.compile('.*123-HELLO.*').match(s)) 

def test_nested_rendering():
    tr1 = TemplateRenderer()
    tr1.addProperty('a', {'b': 'ijk'})
    s = tr1.renderString('This is {{a}}')
    p = re.compile('This is.*b.*ijk')
    assert(p.match(s))
    s = tr1.renderString('This is {{a.b}}')
    assert(s == 'This is ijk')

def test_nested_inline_rendering():
    tr1 = TemplateRenderer()
    tr1.addProperty('a.b', 'ijk')
    s = tr1.renderString('This is {{a}}')
    p = re.compile('This is.*b.*ijk')
    assert(p.match(s))
    s = tr1.renderString('This is {{a.b}}')
    assert(s == 'This is ijk')

def test_nested_and_modification():
    tr1 = TemplateRenderer()
    tr1.addProperty('a', {'b': 'ijk'})
    tr1.addProperty('a', {'c': 'hello'})
    s = tr1.renderString('This is {{a.c}}')
    assert(s == 'This is hello')
    s = tr1.renderString('This is {{a.b}}')
    assert(s == 'This is ijk')
    tr1.addProperty('a', {'d': {'e': 'deep'}})
    tr1.addProperty('a', {'d': {'f': 'deep_also'}})
    assert(tr1.renderString('{{a.d.e}}') == 'deep')
    assert(tr1.renderString('{{a.d.f}}') == 'deep_also')

def test_inheritance():
    tr1 = TemplateRenderer()
    tr1.addProperty('a', 'xyz')
    tr2 = TemplateRenderer(None, tr1)
    assert(tr2)
    tr2.addProperty('b', '{{a}}-HELLO')
    s = tr2.renderString('This is {{b}}')
    assert(s == 'This is xyz-HELLO')

def test_nested_inheritance():
    tr1 = TemplateRenderer()
    tr1.addProperty('a', 'xyz')
    tr2 = TemplateRenderer(None, tr1)
    assert(tr2)
    tr2.addProperty('b', {'c': '{{a}}-BYE'})
    s = tr2.renderString('This is {{b.c}}')
    assert(s == 'This is xyz-BYE')

def test_nested_inheritance():
    tr = TemplateRenderer()
    tr.addProperties({'3': {'b': 'BB', '4.d': 'CD'}})
    s = tr.renderString('This is {{3.4.d}}')
    assert(s == 'This is CD')
