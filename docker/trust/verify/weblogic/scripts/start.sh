#!/bin/bash

set -ue

########### SIGTERM handler ############
function _term() {
   echo "Stopping container."
   echo "SIGTERM received, shutting down the server!"
   ${DOMAIN_HOME}/bin/stopWebLogic.sh
}

########### SIGKILL handler ############
function _kill() {
   echo "SIGKILL received, shutting down the server!"
   kill -9 $childPID
}

# Setting datasource URL
case "$TRUST_DB_DRIVER" in
  oracle)
    export TRUST_DB_URL="jdbc:oracle:thin:@$TRUST_DB_HOST:$TRUST_DB_PORT/$TRUST_DB_NAME"
    ;;
    
  oracle12)
    export TRUST_DB_URL="jdbc:oracle:thin:@$TRUST_DB_HOST:$TRUST_DB_PORT/$TRUST_DB_NAME"
    ;;

  oracle19)
    export TRUST_DB_URL="jdbc:oracle:thin:@//$TRUST_DB_HOST:$TRUST_DB_PORT/$TRUST_DB_NAME"
    ;;

  sqlserver)
    export TRUST_DB_URL="jdbc:sqlserver://$TRUST_DB_HOST:$TRUST_DB_PORT;instance=$TRUST_DB_INSTANCE;databaseName=$TRUST_DB_NAME;"
    ;;

  *)
    echo "Invalid TRUST_DB_DRIVER value '$TRUST_DB_DRIVER'"
    echo "Allowed values are 'oracle12', 'oracle19' and 'sqlserver'"
    exit 1
    ;;
esac

# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

# Define environment variables
export DOMAIN_HOME=$WEBLOGIC_HOME/user_projects/domains/$DOMAIN_NAME
export SERVER_NAME="AdminServer"
export CLASSPATH=$WEBLOGIC_SERVER_DIR/lib/mssql-jdbc-8.4.1.jre8.jar:$WEBLOGIC_SERVER_DIR/lib/ojdbc8-19.3.0.0.jar

echo "Domain Home is: $DOMAIN_HOME"

# Create Domain and deploy application only if 1st execution
if [ ! -f ${DOMAIN_HOME}/servers/$SERVER_NAME/logs/$SERVER_NAME.log ]; then
  PROPERTIES_FILE=$WEBLOGIC_HOME/domain.properties

  # Create an empty domain
  echo "username=${DOMAIN_USERNAME}" > $PROPERTIES_FILE
  echo "password=${DOMAIN_PASSWORD}" >> $PROPERTIES_FILE
  wlst.sh -skipWLSModuleScanning -loadProperties $PROPERTIES_FILE $WEBLOGIC_HOME/create-wls-domain.py

  # Setting admin server credential
  mkdir -p ${DOMAIN_HOME}/servers/$SERVER_NAME/security
  echo "username=${DOMAIN_USERNAME}" >> $DOMAIN_HOME/servers/$SERVER_NAME/security/boot.properties
  echo "password=${DOMAIN_PASSWORD}" >> $DOMAIN_HOME/servers/$SERVER_NAME/security/boot.properties

  # Deploying
  mv ${WEBLOGIC_WEBAPPS_DIR}/app.war ${WEBLOGIC_WEBAPPS_DIR}/$CONTEXT_NAME.war
  DATASOURCE=fffRecordsDataSource wlst.sh -skipWLSModuleScanning $WEBLOGIC_HOME/ds-deploy.py
  DATASOURCE=fffSystemDataSource wlst.sh -skipWLSModuleScanning $WEBLOGIC_HOME/ds-deploy.py
  wlst.sh -skipWLSModuleScanning $WEBLOGIC_HOME/app-deploy.py
fi


# Start Admin Server and tail the logs
${DOMAIN_HOME}/startWebLogic.sh
touch ${DOMAIN_HOME}/servers/$SERVER_NAME/logs/$SERVER_NAME.log
tail -f ${DOMAIN_HOME}/servers/$SERVER_NAME/logs/$SERVER_NAME.log &

childPID=$!
wait $childPID
