import os

def get_env(env_name):
  env = os.environ.get(env_name, None)

  if env is None:
    print(env_name + ' is not set')
    exit(-1)

  return env

# Deployment Information
domainname = get_env('DOMAIN_NAME')
domainhome = get_env('DOMAIN_HOME')
server_name = get_env('SERVER_NAME')

# Deployment Information
webapp_path = get_env('WEBLOGIC_WEBAPPS_DIR')
context_name = get_env('CONTEXT_NAME')
app_version = get_env('TRUST_APP_VERSION')
app_name = 'FircoTrust%s' % app_version

# Read Domain in Offline Mode
readDomain(domainhome)

cd('/')
app = create(app_name, 'AppDeployment')
app.setSourcePath('%s/%s.war' % (webapp_path, context_name))
app.setStagingMode('nostage')

assign('AppDeployment', app_name, 'Target', server_name)

cd('SecurityConfiguration/' + domainname)
set('EnforceValidBasicAuthCredentials','false')

updateDomain()
closeDomain()
exit()
