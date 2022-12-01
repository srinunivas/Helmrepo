import os

def get_env(env_name):
    env = os.environ.get(env_name, None)
    if env is None:
        print env_name + ' is not set'
        exit(-1)
    return env

# Deployment Information
domainname = os.environ.get('DOMAIN_NAME', 'base_domain')
domainhome = os.environ.get('DOMAIN_HOME', '/u01/oracle/user_projects/domains/' + domainname)
admin_name = os.environ.get("ADMIN_NAME", 'AdminServer')


dsname = 'workflow'
db_url = get_env('DB_URL')
db_username = get_env('DB_USER')
db_password = get_env('DB_PASSWORD')
db_vendor = os.environ.get('DB_VENDOR', 'oracle')
dsjndiname='jdbc/continuity'
query_test='SQL SELECT 1 FROM DUAL'
dsdriver='oracle.jdbc.OracleDriver'

if 'sqlserver' == db_vendor.lower():
    dsdriver='com.microsoft.sqlserver.jdbc.SQLServerDriver'
    query_test ='SELECT 1'

print('Database connection:')
print('\tURL: [%s]'%db_url)
print('\tUsername: [%s]'%db_username)
print('\tPassword: [%s]'%('*'*len(db_password)))

# Read Domain in Offline Mode
# ===========================
readDomain(domainhome)

# Create Datasource
# ==================
create(dsname, 'JDBCSystemResource')
cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
cmo.setName(dsname)

cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
create('myJdbcDataSourceParams','JDBCDataSourceParams')
cd('JDBCDataSourceParams/NO_NAME_0')
set('JNDIName', java.lang.String(dsjndiname))
set('GlobalTransactionsProtocol', java.lang.String('None'))

cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
create('myJdbcDriverParams','JDBCDriverParams')
cd('JDBCDriverParams/NO_NAME_0')
set('DriverName', dsdriver)
set('URL', db_url)
set('PasswordEncrypted', db_password)
set('UseXADataSourceInterface', 'false')

print 'create JDBCDriverParams Properties'
create('myProperties','Properties')
cd('Properties/NO_NAME_0')
create('user','Property')
cd('Property/user')
set('Value', db_username)


print 'create JDBCConnectionPoolParams'
cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
create('myJdbcConnectionPoolParams','JDBCConnectionPoolParams')
cd('JDBCConnectionPoolParams/NO_NAME_0')
set('TestTableName', query_test)

# Assign
# ======
assign('JDBCSystemResource', dsname, 'Target', admin_name)

# Update Domain, Close It, Exit
# ==========================
updateDomain()
closeDomain()
exit()
