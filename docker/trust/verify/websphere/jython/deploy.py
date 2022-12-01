# This Jython script is to create JDBCProvider, Datasource, WorkManager,
# QueueConnectionFactory, MessageQueue and Deploy the application

import os
import sys

global AdminApp
global AdminTask
global AdminConfig

def getNodeId (prompt):
  nodeList = AdminConfig.list("Node").split("\n")

  if (len(nodeList) == 1):
    node = nodeList[0]
  else:
    print ""
    print "Available Nodes:"

    nodeNameList = []

    for item in nodeList:
      item = item.rstrip()
      name = getName(item) 

      nodeNameList.append(name)
      print "   " + name

    DefaultNode = nodeNameList[0]
    
    if (prompt == ""):
      prompt = "Select the desired node"

    nodeName = getValidInput(prompt+" ["+DefaultNode+"]:", DefaultNode, nodeNameList )

    index = nodeNameList.index(nodeName)
    node = nodeList[index]

  return node

def getServerId (prompt):
  serverList = AdminConfig.list("Server").split("\n")

  if (len(serverList) == 1):
    server = serverList[0]
  else:
    print ""
    print "Available Servers:"

    serverNameList = []

    for item in serverList:
      item = item.rstrip()
      name = getName(item)

      serverNameList.append(name)
      print "   " + name

    DefaultServer = serverNameList[0]

    if (prompt == ""):
      prompt = "Select the desired server"

    serverName = getValidInput(prompt+" ["+DefaultServer+"]:", DefaultServer, serverNameList )

    index = serverNameList.index(serverName)
    server = serverList[index]

  return server

def getName (objectId):
  endIndex = (objectId.find("(c") - 1)
  stIndex = 0

  if (objectId.find("\"") == 0):
    stIndex = 1

  return objectId[stIndex:endIndex+1]

app_version = os.getenv('TRUST_APP_VERSION')
map_web_mod_to_vh_name = 'FFF Verify Web' if app_version.startswith('4.') else 'app.war'
context = os.getenv('CONTEXT_NAME')

db_username = os.getenv('TRUST_DB_USER')
db_password = os.getenv('TRUST_DB_PWD')
db_url = os.getenv('TRUST_DB_URL')
db_driver = os.getenv('TRUST_DB_DRIVER')

node = getName(getNodeId(''))
server = getName(getServerId(''))
scope = AdminConfig.getid('/Cell:DefaultCell01')

print('Server info:')
print('\tName: %s' % server)
print('\tNode: %s' % node)

print('Application info:')
print('\tVersion: %s' % app_version)
print('\tContext: %s' % context)
print('\tDatabase driver: %s' % db_driver)

print('Database info:')
print('\tUsername: %s' % db_username)
print('\tURL: %s' % db_url)
print('\tPassword: ' + '*' * (len(db_password)))

# Creating JAAS User
AdminTask.createAuthDataEntry('[-alias "dbuser" -user "%s" -password "%s" -description "Database user"]' % (db_username, db_password))
AdminConfig.save()

print('JAAS Users created successfully')

if db_driver == 'oracle':
  # Create JDBC Provider
  provider = AdminConfig.create('JDBCProvider', scope, [
    ['name', 'oracle19-jdbc8-provider'],
    ['classpath', '/opt/IBM/WebSphere/AppServer/lib/ojdbc8-19.3.0.0.jar'],
    ['implementationClassName', 'oracle.jdbc.pool.OracleConnectionPoolDataSource']
  ])

  AdminConfig.save()

  print('JDBC provider created successfully...')
  print('\tJDBC Provider = ' + provider)

  # Create Datasources using the JDBC Provider
  fffRecordsDataSource = AdminConfig.create('DataSource', provider, [
    ['name', 'fffRecordsDataSource'],
    ['jndiName', 'jdbc/fffRecordsDataSource'],
    ['datasourceHelperClassname', 'com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper'],
    ['authDataAlias', '%s/dbuser' % node],
    ['description', 'Oracle Records Datasource for Trust Verify Web']
  ])

  fffSystemDataSource = AdminConfig.create('DataSource', provider, [
    ['name', 'fffSystemDataSource'],
    ['jndiName', 'jdbc/fffSystemDataSource'],
    ['datasourceHelperClassname', 'com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper'],
    ['authDataAlias', '%s/dbuser' % node],
    ['description', 'Oracle System Datasource for Trust Verify Web']
  ])

  fffRecordsPropertySet = AdminConfig.create('J2EEResourcePropertySet', fffRecordsDataSource, [])

  AdminConfig.create('J2EEResourceProperty', fffRecordsPropertySet, [['name', 'URL'], ['value', db_url]])
  AdminConfig.create('J2EEResourceProperty', fffRecordsPropertySet, [['name', 'preTestSQLString'], ['value', 'SELECT 1 FROM DUAL']])

  fffSystemPropertySet = AdminConfig.create('J2EEResourcePropertySet', fffSystemDataSource, [])

  AdminConfig.create('J2EEResourceProperty', fffSystemPropertySet, [['name', 'URL'], ['value', db_url]])
  AdminConfig.create('J2EEResourceProperty', fffSystemPropertySet, [['name', 'preTestSQLString'], ['value', 'SELECT 1 FROM DUAL']])

  AdminConfig.save()

  print('Datasources created successfully...')
  print('\tSystem Datasource = ' + fffSystemDataSource)
  print('\tRecords Datasource = ' + fffRecordsDataSource)
elif db_driver == 'sqlserver':
  # Create JDBC Provider
  provider = AdminTask.createJDBCProvider(
    '[-scope Cell=DefaultCell01'
    ' -databaseType "SQL Server"'
    ' -providerType "Microsoft SQL Server JDBC Driver"'
    ' -implementationType "Connection pool data source"'
    ' -name "SQL Server JDBC Driver"'
    ' -description "IBM WebSphere Connect JDBC driver for MS SQL Server"'
    ' -classpath /opt/IBM/WebSphere/AppServer/lib/mssql-jdbc-8.4.1.jre8.jar'
    ' -nativePath ""'
    ']')

  AdminConfig.save()
  
  print('JDBC provider created successfully...')
  print('\tJDBC Provider = ' + provider)

  # Create Datasource using the JDBC Provider
  fffSystemDataSource = AdminConfig.create('DataSource', provider, [
    ['name', 'fffSystemDataSource'],
    ['jndiName', 'jdbc/fffSystemDataSource'],
    ['datasourceHelperClassname', 'com.ibm.websphere.rsadapter.MicrosoftSQLServerDataStoreHelper'],
    ['authDataAlias', '%s/dbuser' % node],
    ['description', 'SQL Server System Datasource for Trust Verify Web']
  ])

  fffRecordsDataSource = AdminConfig.create('DataSource', provider, [
    ['name', 'fffRecordsDataSource'],
    ['jndiName', 'jdbc/fffRecordsDataSource'],
    ['datasourceHelperClassname', 'com.ibm.websphere.rsadapter.MicrosoftSQLServerDataStoreHelper'],
    ['authDataAlias', '%s/dbuser' % node],
    ['description', 'SQL Server Records Datasource for Trust Verify Web']
  ])

  fffRecordsPropertySet = AdminConfig.create('J2EEResourcePropertySet', fffRecordsDataSource, [])

  AdminConfig.create('J2EEResourceProperty', fffRecordsPropertySet, [['name', 'URL'], ['value', db_url]])
  AdminConfig.create('J2EEResourceProperty', fffRecordsPropertySet, [['name', 'preTestSQLString'], ['value', 'SELECT 1']])

  fffSystemPropertySet = AdminConfig.create('J2EEResourcePropertySet', fffSystemDataSource, [])

  AdminConfig.create('J2EEResourceProperty', fffSystemPropertySet, [['name', 'URL'], ['value', db_url]])
  AdminConfig.create('J2EEResourceProperty', fffSystemPropertySet, [['name', 'preTestSQLString'], ['value', 'SELECT 1']])

  AdminConfig.save()

  print('Datasources created successfully...')
  print('\tSystem Datasource = ' + fffSystemDataSource)
  print('\tRecords Datasource = ' + fffRecordsDataSource)

# Uninstall all default apps
AdminApp.uninstall('query')

# Enable debug port
AdminTask.setJVMProperties('[-nodeName %s -serverName %s -debugMode true -debugArgs "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=7777"]' % (node, server))

# Deploy the application and channge the class loader principle
print('Now installing the application')

AdminApp.install('/work/config/app.war', '[-node %s -cell DefaultCell01 -server %s -appname "Firco Trust %s" -contextroot /%s -usedefaultbindings -defaultbinding.datasource.jndi "jdbc/fffRecordsDataSource" -MapWebModToVH [[ "%s" app.war,WEB-INF/web.xml default_host]] -reloadEnabled]' % (node, server, app_version, context, map_web_mod_to_vh_name))
AdminConfig.save()

print('Application installed successfully')
