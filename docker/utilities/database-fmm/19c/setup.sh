#!/bin/bash

set -e

echo "*****************************************************************"
echo "*******Starting docker\utilities\database-fmm\19c\setup.sh*******"
echo "*****************************************************************"

lsnrctl start
echo startup\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba

echo "***DATABASE_HOME:$DATABASE_HOME***"
echo

for f in $(ls script-sql/*); do
  echo "Updating sql file $f"
  case "$f" in
    script-sql/batch-schema-oracle10g_TS.sql)   echo "Updating sql file : batch-schema-oracle10g_TS.sql $f"; \
                                                cat $f \
                                                | sed -e "s%DEFINE TS_DATA = &1%DEFINE TS_DATA = $DB_TS%" \
                                                | sed -e "s%DEFINE TS_INDEX = &2%DEFINE TS_INDEX = $DB_TS%" \
                                                > setup/0002.create.batch.database.as.user.sql; \
                                                head -21 setup/0002.create.batch.database.as.user.sql;;
    script-sql/FMM_Creation_Oracle.sql)         echo "Updating sql file : FMM_Creation_Oracle.sql $f"; \
                                                cat $f \
                                                | sed -e "s%DEFINE TS_DATA = &1%DEFINE TS_DATA = $DB_TS%" \
                                                | sed -e "s%DEFINE TS_INDEX = &2%DEFINE TS_INDEX = $DB_TS%" \
                                                > setup/0003.create.database.as.user.sql; \
                                                head -21 setup/0003.create.database.as.user.sql;;
    script-sql/ORACLE_FMM_TABLE_CREATION.sql)   echo "Updating sql file $f"; \
                                                cat $f \
                                                | sed -e "s%ACCEPT LOGDIR%DEFINE LOGDIR = . --%" \
                                                | sed -e "s%ACCEPT TS_DATA%DEFINE TS_DATA = $DB_TS --%" \
                                                | sed -e "s%ACCEPT TS_INDEX%DEFINE TS_INDEX = $DB_TS --%" \
                                                > setup/0004.create.database.as.user.sql; \
                                                head -21 setup/0004.create.database.as.user.sql;;
    script-sql/ORACLE_FMM_TABLE_INSERT.sql)   echo "Updating sql file $f"; \
                                                cat $f \
                                                | sed -e "s%ACCEPT LOGDIR%DEFINE LOGDIR = . --%" \
                                                > setup/0005.insert.database.as.user.sql; \
                                                head -21 setup/0005.insert.database.as.user.sql;; 
    *)                                          echo "Ignoring sql file $f";;                            
  esac
  echo                            
done

for f in $(ls $DATABASE_HOME/setup/*); do
  echo "found file $f"
  case "$f" in
    *.sh)
      echo "[SETUP] $0: running $f"; source "$f" ;;
    *.root.sql)
      echo "[SETUP1] $0: running $f as root"; sqlplus -silent sys/$ORACLE_PWD@$ORACLE_SID as sysdba @$f $DB_USER $DB_PWD $DB_TS ;;
    *.user.sql)
      echo "[SETUP] $0: running $f as user"; sqlplus -silent $DB_USER/$DB_PWD@$ORACLE_SID @$f ;;
    *)
      echo "[SETUP] $0: ignoring $f" ;;
  esac
  echo
done

echo "**************************************************************"
echo "********Ending docker\utilities\database-fmm\19c\setup.sh*****"
echo "**************************************************************"

trap "echo shutdown immediate\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba" INT TERM
