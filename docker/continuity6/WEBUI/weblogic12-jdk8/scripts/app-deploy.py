import os


# Deployment Information
domainname = os.environ.get('DOMAIN_NAME', 'base_domain')
domainhome = os.environ.get('DOMAIN_HOME', '/u01/oracle/user_projects/domains/' + domainname)
webapp_path = os.environ.get('WEBAPPS_LOCATION', '/u01/oracle/webapps')
webapp_name = 'continuity'


readDomain(domainhome)

cd('/')
app = create('cty', 'AppDeployment')
app.setSourcePath(webapp_path+'/'+webapp_name+'.war')
app.setStagingMode('nostage')

assign('AppDeployment', 'cty', 'Target', 'AdminServer')

cd('SecurityConfiguration/'+domainname)
set('EnforceValidBasicAuthCredentials','false')

updateDomain()
closeDomain()
exit()


