# This Jython script is to create JDBCProvider, Datasource, WorkManager, QueueConnectionFactory, MessageQueue and Deploy the application
# Maintainer: El Abed Oussama & Mohammed Bouabid

#To set the Java Heap size for the WAS container
# AdminTask.setJVMMaxHeapSize('-serverName server1 -nodeName DefaultNode01 -maximumHeapSize 4168')
# AdminConfig.save()
# print("Java Heap size is set as 4 GB ...")
import os

db_username = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_url = os.getenv('DB_URL')

print ("database info: ")
print ("\t username: " + db_username)
print ("\t url: " + db_url)
print ("\t password: " + '*'*(len(db_password)))

def removeAllDisabledSessionCookies() :
    """
    There can be secure session cookies that will deny cookie config in web.xml of continuity and lead to SRVE8111E
    Removes all of these session cookies, return list of disabled cookies, which should be empty at the end of this function
    """

    print ("Now removing All Disabled Session Cookies......")

    # this gets the list of secure session cookies
    cell_id = AdminConfig.getid( '/Cell:DefaultCell01' )
    sessionManager = AdminConfig.list('SecureSessionCookie', cell_id).split('\n')

    if (sessionManager == ['']):
        print ("No secure session cookies for DefaultCell01 ......")
        return AdminTask.listDisabledSessionCookie() # nothing to delete
    else:
        for sessionCookie in sessionManager:
            size = len(sessionCookie)
            print ("\tsessionCookie = " + sessionCookie)

            # a little parsing
            if sessionCookie[size-1] == ')':
                sessionCookie = sessionCookie[1:size-1]
            else:
                sessionCookie = sessionCookie[1:size-2]

            attr = "-cookieId " + sessionCookie
            AdminTask.removeDisabledSessionCookie(attr)

        #endfor

    return AdminTask.listDisabledSessionCookie()

#end_def

#Creating JAAS User
AdminTask.createAuthDataEntry('[-alias "dbuser" -user "'+db_username+'" -password "'+db_password+'"]')
AdminConfig.save()
print ("JAAS Users created successfully...")

#Create JDBC Provider
scope = AdminConfig.getid('/Cell:DefaultCell01')
newProvider = AdminConfig.create('JDBCProvider', scope, [
    ['name', 'docker-oracle-jdbc-provider'],
    ['classpath', '/opt/IBM/WebSphere/AppServer/lib/ojdbc8-19.3.0.0.jar'],
    ['implementationClassName', 'oracle.jdbc.pool.OracleConnectionPoolDataSource']
])
AdminConfig.save()
print ("JDBCProvider created successfully...")
print ("\tjdbcProvider = " + newProvider)

#Create Datasource using the JDBC Provider
newds = AdminConfig.create('DataSource', newProvider, [
    ['name', 'workflow'],
    ['jndiName', 'jdbc/continuity'],
    ['datasourceHelperClassname', 'com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper'],
    ['authDataAlias', 'DefaultNode01/dbuser'],
    ['description', 'Oracle DataSource for Continuity WEBUI Docker']
])
propSet = AdminConfig.create('J2EEResourcePropertySet', newds, [])
AdminConfig.create('J2EEResourceProperty', propSet, [['name', 'URL'], ['value', db_url]])
AdminConfig.create('J2EEResourceProperty', propSet, [['name', 'preTestSQLString'], ['value', 'SELECT 1 FROM DUAL']])
AdminConfig.save()
print ("Datasource created successfully...")
print ("\tdataSource = " + newds)

listDisabledSessionCookies = removeAllDisabledSessionCookies()
if len(listDisabledSessionCookies) == 0 :
    print ("Disabled Session cookies list is successfully cleaned ...")
else:
    print ("There are still disabled session cookies, may lead to SRVE8111E error...")

#Deploy the application and channge the class loader principle
print ("Now installing the Application......")
AdminApp.install('/work/config/continuity.war','[-node DefaultNode01 -cell DefaultCell01 -server server1 -appname continuity -contextroot /continuity -usedefaultbindings -defaultbinding.datasource.jndi "jdbc/contiuity" -MapWebModToVH [[ continuity.war continuity.war,WEB-INF/web.xml default_host]] -reloadEnabled]')
AdminConfig.save()
print ("Application installed successfully...")



###### SQL Server

#Creating JAAS User
# AdminTask.createAuthDataEntry('[-alias "dbsqlserverUser" -user "sa" -password "Hello00"]')
# AdminConfig.save()
# print ("JAAS Users created successfully...")

# AdminTask.createJDBCProvider('[-scope Cell=DefaultCell01 -databaseType "SQL Server" -providerType "Microsoft SQL Server JDBC Driver" -implementationType "Connection pool data source" -name "SQL Server JDBC Driver" -description "IBM WebSphere Connect JDBC driver for MS SQL Server." -classpath /deploy/drivers/sqljdbc4-2.0.jar -nativePath "" ]')
# AdminConfig.save()
# print ("JDBCProviders created successfully...")


# strDSArgs = '[-name "workflow" -jndiName jdbc/continuity -dataStoreHelperClassName com.ibm.websphere.rsadapter.MicrosoftSQLServerDataStoreHelper -containerManagedPersistence false -componentManagedAuthenticationAlias DefaultNode01/dbsqlserverUser -configureResourceProperties [[databaseName java.lang.String "T_5910_P7"] [portNumber java.lang.Integer 1433 ] [serverName java.lang.String "10.55.63.6"]]]'

# #Create Datasource using the JDBC Provider
# prvdrSQLSERVER = AdminConfig.getid('/JDBCProvider:SQL Server JDBC Driver/')
# AdminTask.createDatasource(prvdrSQLSERVER, strDSArgs)
# AdminConfig.save()
# print ("Datasources created successfully...")