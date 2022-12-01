import re
import unittest

from shadoker.shadoker_globals import camelToKebabCase

def test_case_converter():
    assert(camelToKebabCase(None) == None)
    assert(camelToKebabCase(44) == 44)
    assert(camelToKebabCase('') == '')
    assert(camelToKebabCase('NotCamelCase') == 'not-camel-case')
    assert(camelToKebabCase("realCamelCase") == "real-camel-case")
    assert(camelToKebabCase('camel2_camel2_case') == 'camel2_camel2_case')
    assert(camelToKebabCase('getHTTPResponseCode') == 'get-http-response-code')
    assert(camelToKebabCase('HTTPResponseCodeXYZ') == 'http-response-code-xyz')

