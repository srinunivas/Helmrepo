#!/bin/bash

set -u

case "$TRUST_DB_DRIVER" in
  oracle)
    TRUST_DB_DRIVER="oracle.jdbc.OracleDriver"
    TRUST_DB_URL="jdbc:oracle:thin:@$TRUST_DB_HOST:$TRUST_DB_PORT/$TRUST_DB_NAME"
    ;;
    
  oracle12)
    TRUST_DB_DRIVER="oracle.jdbc.OracleDriver"
    TRUST_DB_URL="jdbc:oracle:thin:@$TRUST_DB_HOST:$TRUST_DB_PORT/$TRUST_DB_NAME"
    ;;

  oracle19)
    TRUST_DB_DRIVER="oracle.jdbc.OracleDriver"
    TRUST_DB_URL="jdbc:oracle:thin:@//$TRUST_DB_HOST:$TRUST_DB_PORT/$TRUST_DB_NAME"
    ;;

  sqlserver)
    TRUST_DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
    TRUST_DB_URL="jdbc:sqlserver://$TRUST_DB_HOST:$TRUST_DB_PORT;instance=$TRUST_DB_INSTANCE;databaseName=$TRUST_DB_NAME;"
    ;;

  *)
    echo "Invalid TRUST_DB_DRIVER value '$TRUST_DB_DRIVER'"
    echo "Allowed values are 'oracle12', 'oracle19' and 'sqlserver'"
    exit 1
    ;;
esac

set +u

DATABASE_VARS="-DTRUST_DB_DRIVER='${TRUST_DB_DRIVER}' -DTRUST_DB_URL='${TRUST_DB_URL}' -DTRUST_DB_USER='${TRUST_DB_USER}' -DTRUST_DB_PWD='${TRUST_DB_PWD}'"
export CATALINA_OPTS="${CATALINA_OPTS} -Dauthentication.method=${AUTH_METHOD:-HEAVY_LOGIN} ${DATABASE_VARS}"

case "$AUTH_METHOD" in
  LDAP)
    echo "Activating LDAP Basic Authentication settings on $CATALINA_HOME/conf/server.xml"
    LDAP_VARS="-Dldap.roleBase='${LDAP_BASE_DN}' -Dldap.url='${LDAP_SERVER}' -Dldap.connectionName='${LDAP_USER}' -Dldap.connectionPassword='${LDAP_PASSWORD}' -Dldap.userBase='${LDAP_USER_BASE}' -Dldap.userSearch='${LDAP_USER_SEARCH}' -Dldap.roleName='${LDAP_ROLE_ATTRIBUTE_NAME}' -Dldap.roleSearch='${LDAP_ROLE_SEARCH_PATTERN}'"
    export CATALINA_OPTS="${CATALINA_OPTS} ${LDAP_VARS}"
    cp -f $CATALINA_HOME/conf/server-default.xml $CATALINA_HOME/conf/server.xml
    ;;

  *)
    echo "Activating settings for Trust Verify on $CATALINA_HOME/conf/server.xml"
    cp -f $CATALINA_HOME/conf/server-default.xml $CATALINA_HOME/conf/server.xml
    ;;
esac

if [ -f $CATALINA_HOME/webapps/app.war ]; then
  mv $CATALINA_HOME/webapps/app.war $CATALINA_HOME/webapps/$CONTEXT_NAME.war
  sed -i "s/trust/$CONTEXT_NAME/g" /usr/local/tomcat/webapps/error.html
fi

if [ "$REMOTE_DEBUGGING" = 'true' ]; then
  export JPDA_ADDRESS="0.0.0.0:5005"
  export JPDA_TRANSPORT="dt_socket"

  /usr/local/tomcat/bin/catalina.sh jpda run
else
  /usr/local/tomcat/bin/catalina.sh run
fi
