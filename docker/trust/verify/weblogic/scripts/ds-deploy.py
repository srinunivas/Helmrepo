import os

def get_env(env_name):
  env = os.environ.get(env_name, None)

  if env is None:
    print(env_name + ' is not set')
    exit(-1)

  return env

# Deployment Information
domainhome = get_env('DOMAIN_HOME')
server_name = get_env('SERVER_NAME')

dsname = os.getenv('DATASOURCE')
db_name = os.getenv('TRUST_DB_NAME')
db_url = get_env('TRUST_DB_URL')
db_username = get_env('TRUST_DB_USER')
db_password = get_env('TRUST_DB_PWD')
db_vendor = get_env('TRUST_DB_DRIVER')
query_test = 'SQL SELECT 1 FROM DUAL'
driver_classname = 'oracle.jdbc.OracleDriver'

if db_vendor == 'sqlserver':
  driver_classname='com.microsoft.sqlserver.jdbc.SQLServerDriver'
  query_test ='SELECT 1'

print('Database connection:')
print('\tURL: %s'%db_url)
print('\tUsername: %s' % db_username)
print('\tPassword: %s' % ('*'*len(db_password)))

# Read Domain in Offline Mode
readDomain(domainhome)

# Creating datasources
print('Creating datasource %s' % dsname)

create(dsname, 'JDBCSystemResource')
cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
cmo.setName(dsname)

cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
create('myJdbcDataSourceParams','JDBCDataSourceParams')
cd('JDBCDataSourceParams/NO_NAME_0')
set('JNDIName', java.lang.String('jdbc/%s' % dsname))
set('GlobalTransactionsProtocol', java.lang.String('None'))

cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
create(dsname + 'JdbcDriverParams','JDBCDriverParams')
cd('JDBCDriverParams/NO_NAME_0')
set('DriverName', driver_classname)
set('URL', db_url)
set('PasswordEncrypted', db_password)
set('UseXADataSourceInterface', 'false')

print('Creating JDBCDriverParams Properties')
create(dsname + 'Properties', 'Properties')
cd('Properties/NO_NAME_0')
create('user', 'Property')
cd('Property/user')
set('Value', db_username)

cd('../../')
create('databaseName', 'Property')
cd('Property/databaseName')
set('Value', db_name)

print('Creating JDBCConnectionPoolParams')
cd('/JDBCSystemResource/' + dsname + '/JdbcResource/' + dsname)
create(dsname + 'JdbcConnectionPoolParams', 'JDBCConnectionPoolParams')
cd('JDBCConnectionPoolParams/NO_NAME_0')
set('TestTableName', query_test)

# Assign
assign('JDBCSystemResource', dsname, 'Target', server_name)

updateDomain()
closeDomain()
exit()
