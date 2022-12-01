#!/bin/bash

#echo on
#set -x

# SETUP-UP SCRIPTS ARE EXECUTED EACH TIME THE CONTAINER STARTS IN SEQUENCE

source /home/oracle/.bashrc

DBA_USER=sys
DBA_PASSWORD=Fircosoft00
DB_SID=orclpdb1
DB_USER=CTY_${SQL_MAIN_VERSION//./_}
ADV_REP_DB_USER=ADV_REP_${SQL_BUSINESS_OBJECTS_VERSION//./_}
DB_PWD=hello00

TS_DATA="USERS"
TS_INDEX="USERS"

[[ -f ~/.initialized ]] && { echo "Users $DB_USER and $ADV_REP_DB_USER already created." && echo "" && exit 0 ; }
touch ~/.initialized

sqlplus $DBA_USER/$DBA_PASSWORD@$DB_SID as sysdba @/home/oracle/sql/createOracleUser.sql $DB_USER $DB_PWD
sqlplus $DB_USER/$DB_PWD@$DB_SID @/home/oracle/sql/Continuity_${SQL_MAIN_VERSION//./}_Creation_Oracle.sql $TS_DATA $TS_INDEX 

sqlplus $DBA_USER/$DBA_PASSWORD@$DB_SID as sysdba @/home/oracle/sql/createOracleUser.sql $ADV_REP_DB_USER $DB_PWD
sqlplus $ADV_REP_DB_USER/$DB_PWD@$DB_SID @/home/oracle/sql/AdvancedReporting_${SQL_BUSINESS_OBJECTS_VERSION//./}_Creation_Oracle.sql $TS_DATA $TS_INDEX 
