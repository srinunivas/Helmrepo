#!/bin/bash

#echo on
#set -x

# SETUP-UP SCRIPTS ARE EXECUTED EACH TIME THE CONTAINER STARTS IN SEQUENCE

source /home/oracle/.bashrc

DBA_USER=sys
DBA_PASSWORD=Fircosoft00
DB_SID=orclpdb1

TS_DATA="USERS"
TS_INDEX="USERS"

[[ -f ~/.initialized ]] && { echo "DB already initialized. Schema creation is skipped." && echo "" && return ; }
touch ~/.initialized

if [ ! -z "${SQL_MAIN_VERSION}" ]; then
    sqlplus $DBA_USER/$DBA_PASSWORD@$DB_SID as sysdba @/home/oracle/sql/createOracleUser.sql $DB_USER $DB_USER_PWD
    sqlplus $DB_USER/$DB_USER_PWD@$DB_SID @/home/oracle/sql/Continuity_${SQL_MAIN_VERSION//./}_Creation_Oracle.sql $TS_DATA $TS_INDEX 
fi;

if [ ! -z "${SQL_BUSINESS_OBJECTS_VERSION}" ]; then
    sqlplus $DBA_USER/$DBA_PASSWORD@$DB_SID as sysdba @/home/oracle/sql/createOracleUser.sql $ADV_REP_DB_USER $DB_USER_PWD
    sqlplus $ADV_REP_DB_USER/$DB_USER_PWD@$DB_SID @/home/oracle/sql/AdvancedReporting_${SQL_BUSINESS_OBJECTS_VERSION//./}_Creation_Oracle.sql $TS_DATA $TS_INDEX 
fi;
