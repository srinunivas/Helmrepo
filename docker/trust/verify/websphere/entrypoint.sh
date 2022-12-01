#!/bin/bash

set -u

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

echo "Datasource and Deployment configuration"
/work/configure.sh

echo "Starting server..."
/work/start_server.sh
