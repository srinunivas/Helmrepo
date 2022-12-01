import platform

from shadoker.shadoker_globals import sanitizeArgument

def test_sanitizeArgument():
    assert(sanitizeArgument(None) == '')
    assert(sanitizeArgument(33) == 33)
    if (platform.system() == 'Windows'):
        assert(sanitizeArgument('jenkins-deploy.fircosoft.net/example/mycomponentb2:1.0-p66') == 'jenkins-deploy.fircosoft.net/example/mycomponentb2:1.0-p66')
        assert(sanitizeArgument('jenkins-deploy\\example:mycomponentb2:::latest:yes') == 'jenkins-deploy^\\example:mycomponentb2:::latest:yes')
        assert(sanitizeArgument("{\"name\": \"jenkins-deploy.fircosoft.net/continuity5/filterengine-oraclelinux:5.7.5.2\", \"product\": \"filter\", \"asset\": \"filter_engine\", \"version\": \"\", \"digest\": \"sha256:f5577ef777913e1ed9a149b167d6af3f37f1dfb3efbc97fb8908fe6e06c85d59\", \"buildDate\": \"2020-07-21T08:23:50.993Z\", \"labels\": {\"maintainer\": \"Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>\"}}") == "{\"name\": \"jenkins-deploy.fircosoft.net/continuity5/filterengine-oraclelinux:5.7.5.2\", \"product\": \"filter\", \"asset\": \"filter_engine\", \"version\": \"\", \"digest\": \"sha256:f5577ef777913e1ed9a149b167d6af3f37f1dfb3efbc97fb8908fe6e06c85d59\", \"buildDate\": \"2020-07-21T08:23:50.993Z\", \"labels\": {\"maintainer\": \"Emmanuel MESSEGUE ^<emmanuel.messegue@fircosoft.com^>\"}}")
    else:
        assert(sanitizeArgument('jenkins-deploy.fircosoft.net/example/mycomponentb2:1.0-p66') == 'jenkins-deploy.fircosoft.net/example/mycomponentb2:1.0-p66')
        assert(sanitizeArgument('jenkins-deploy\\example:mycomponentb2:::latest:yes') == 'jenkins-deploy\\example:mycomponentb2:::latest:yes')
        assert(sanitizeArgument("{\"name\": \"jenkins-deploy.fircosoft.net/continuity5/filterengine-oraclelinux:5.7.5.2\", \"product\": \"filter\", \"asset\": \"filter_engine\", \"version\": \"\", \"digest\": \"sha256:f5577ef777913e1ed9a149b167d6af3f37f1dfb3efbc97fb8908fe6e06c85d59\", \"buildDate\": \"2020-07-21T08:23:50.993Z\", \"labels\": {\"maintainer\": \"Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>\"}}") == "{\"name\": \"jenkins-deploy.fircosoft.net/continuity5/filterengine-oraclelinux:5.7.5.2\", \"product\": \"filter\", \"asset\": \"filter_engine\", \"version\": \"\", \"digest\": \"sha256:f5577ef777913e1ed9a149b167d6af3f37f1dfb3efbc97fb8908fe6e06c85d59\", \"buildDate\": \"2020-07-21T08:23:50.993Z\", \"labels\": {\"maintainer\": \"Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>\"}}")

def test_sanitizeArgumentList():
    if (platform.system() == 'Windows'):
        assert(sanitizeArgument([]) == [])
        assert(sanitizeArgument(['a', 'b']) == ['a', 'b'])
        assert(sanitizeArgument(['a', 33, '^b']) == ['a', 33, '^^b'])
        assert(sanitizeArgument(['a', None, '>b']) == ['a', '', '^>b'])
    else:
        assert(sanitizeArgument([]) == [])
        assert(sanitizeArgument(['a', 'b']) == ['a', 'b'])
        assert(sanitizeArgument(['a', 33, '^b']) == ['a', 33, '^b'])
        assert(sanitizeArgument(['a', None, '>b']) == ['a', '', '>b'])
        