from shadoker.shadoker_globals import sanitizeDirectoryName

def test_sanitizeDirectoryName():
    assert(sanitizeDirectoryName('jenkins-deploy.fircosoft.net/example/mycomponentb2:1.0-p66') == 'jenkins-deploy.fircosoft.net_example_mycomponentb2@1.0-p66')
    assert(sanitizeDirectoryName('jenkins-deploy\\example:mycomponentb2:::latest:yes') == 'jenkins-deploy_example@mycomponentb2@@@latest@yes')
    assert(sanitizeDirectoryName(None) == None)
    assert(sanitizeDirectoryName([]) == [])
