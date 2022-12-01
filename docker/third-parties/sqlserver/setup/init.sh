#!/bin/bash

set -u

TIMEOUT=30

export DB_NAME=$DB_NAME
export DB_USERNAME=$DB_USERNAME
export DB_PASSWORD=$DB_PASSWORD
export SA_PASSWORD=$SA_PASSWORD

function wait-sqlserver-startup() {
  sleep 3

  for i in `seq $TIMEOUT`; do
    echo "Checking is SQL Server is available (${i}s)..."
    curl --fail localhost:1433 > /dev/null 2>&1

    if [ $? -eq 52 ]; then
      echo "SQL Server is up"
      sleep 2
      $@
      exit 0
    fi

    sleep 1
  done

  echo "Operation timed out" >&2
  kill -9 $SQLSERVER_PID
  exit 1
}

function setup() {
  echo "Database setup"

  for f in $(ls $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/*); do
    echo "Found setup file $f"
    case "$f" in
      *.sh)
        echo "[SETUP] $0: running $f"
        source "$f"
        ;;

      *.root.sql) 
        echo "[SETUP] $0: running $f as sa"; 
        sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i "$f"
        ;;

      *.user.sql) 
        echo "[SETUP] $0: running $f as $DB_USERNAME"
        sqlcmd -S localhost -U $DB_USERNAME -P $DB_PASSWORD -d $DB_NAME -i "$f"
        ;;

      *)
        echo "[SETUP] $0: ignoring $f"
        ;;
    esac
    echo
  done

  echo "Gracefully stop SQL Server by sending SIGINT signal"
  kill -2 $SQLSERVER_PID
}

sudo -u mssql SA_PASSWORD=$SA_PASSWORD /opt/mssql/bin/sqlservr --accept-eula &

SQLSERVER_PID=$!

wait-sqlserver-startup setup
