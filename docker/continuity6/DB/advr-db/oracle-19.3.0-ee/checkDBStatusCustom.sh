#!/bin/bash

# Call original checkDBStatus.sh script
#---------------
$ORACLE_BASE/checkDBStatus.sh
ret=$?
[[ "$ret" != "0" ]] && exit $ret


# Don't check the modifications done in start files before it is needed.
#---------------
[[ ! -f ~/.checkStartUpModifications ]] && exit $ret


# Check it continuity is ready to use
#---------------
DB_USER_PWD='hello00'
DB_USER=ADVR_${SQL_ADVR_VERSION//./_}
status=`sqlplus -s $DB_USER/$DB_USER_PWD@orclpdb1 << EOF
   set heading off;
   set pagesize 0;
   SELECT DISTINCT VERSION FROM FIRCO_WKF_DB_VERSIONS WHERE DATABASE_NAME = 'Continuity';
   exit;
EOF`
ret=$?
if [ $ret -eq 0 ] && [ "$status" = "$SQL_ADVR_VERSION" ]; then
   echo $DB_USER existency successfully checked.
   :
# PDB is not open
elif [ "$status" != "$SQL_ADVR_VERSION" ]; then
   echo $DB_USER not present in db.
   exit 3;
# SQL Plus execution failed
else
   echo SQL Plus execution failed
   exit 2;
fi;