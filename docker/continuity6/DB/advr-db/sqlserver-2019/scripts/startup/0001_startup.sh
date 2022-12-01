#!/bin/bash

sa_password=$1

/opt/mssql/bin/sqlservr --accept-eula &

status=1
while [ $status -ne 0 ]
do
  sleep 1
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $sa_password -Q "select 1"
  status=$?
done

/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $sa_password -i /opt/mssql/createMssqlUser.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U ADVR_DOCKER  -P 'hello00' -Q " CREATE DATABASE advancedReportingDB"
/opt/mssql-tools/bin/sqlcmd -S localhost -U ADVR_DOCKER  -P 'hello00' -d "advancedReportingDB" -i /opt/mssql/advancedReporting.sql

pkill sqlservr
