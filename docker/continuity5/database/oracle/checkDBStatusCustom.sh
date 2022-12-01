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
if [ ! -z "${SQL_MAIN_VERSION}" ]; then
   status=`sqlplus -s $DB_USER/$DB_USER_PWD@orclpdb1 << EOF
      set heading off;
      set pagesize 0;
      SELECT DISTINCT VERSION FROM FIRCO_WKF_DB_VERSIONS WHERE DATABASE_NAME = 'Continuity';
      exit;
EOF`
   ret=$?
   if [ $ret -eq 0 ] && [ "$status" = "$SQL_MAIN_VERSION" ]; then
      echo $DB_USER existency successfully checked.
      :
   # PDB is not open
   elif [ "$status" != "$SQL_MAIN_VERSION" ]; then
      echo $DB_USER not present in db.
      exit 3;
   # SQL Plus execution failed
   else
      echo SQL Plus execution failed
      exit 2;
   fi;
fi;


# Check it adv. reporting is ready to use
#---------------
if [ ! -z "${SQL_BUSINESS_OBJECTS_VERSION}" ]; then
   status=`sqlplus -s $ADV_REP_DB_USER/$DB_USER_PWD@orclpdb1 << EOF
      set heading off;
      set pagesize 0;
      SELECT DISTINCT DB_VERSION_ALIGNMENT FROM FOF_DB_VERSION WHERE DB_VERSION_ALIGNMENT LIKE 'BO-%';
      exit;
EOF`
   ret=$?
   if [ $ret -eq 0 ] && [ "$status" = "BO-${SQL_BUSINESS_OBJECTS_VERSION}" ]; then
      echo $ADV_REP_DB_USER existency successfully checked.
      exit 0;
   # PDB is not open
   elif [ "$status" != "BO-${SQL_BUSINESS_OBJECTS_VERSION}" ]; then
      echo $ADV_REP_DB_USER not present in db.
      exit 3;
   # SQL Plus execution failed
   else
      echo SQL Plus execution failed
      exit 2;
   fi;
fi;
