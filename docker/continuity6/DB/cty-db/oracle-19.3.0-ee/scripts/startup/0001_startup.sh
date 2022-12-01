#!/bin/bash

#echo on
#set -x

# SETUP-UP SCRIPTS ARE EXECUTED EACH TIME THE CONTAINER STARTS IN SEQUENCE

source /home/oracle/.bashrc

DBA_USER=sys
DBA_PASSWORD=Fircosoft00
DB_SID=orclpdb1
DB_USER=CTY_DOCKER
DB_PWD=hello00

TS_DATA="USERS"
TS_INDEX="USERS"

[[ -f ~/.initialized ]] && { echo "Users $DB_USER already created." && echo "" && exit 0 ; }
touch ~/.initialized

sqlplus $DBA_USER/$DBA_PASSWORD@$DB_SID as sysdba @/home/oracle/sqlhelpers/createOracleUser.sql $DB_USER $DB_PWD

ls -al /home/oracle/sqlmain

for filename in /home/oracle/sqlmain/*.sql; do                                                                                           ✔ 
    [ -e "$filename" ] || continue
    echo $filename
    sqlplus $DB_USER/$DB_PWD@$DB_SID @$filename $TS_DATA $TS_INDEX
done

echo "continuity database created successfully" > ~/.checkDbCreation