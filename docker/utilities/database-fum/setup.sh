#!/bin/bash

set -e

echo "Starting database"
su oracle -c "/u01/app/oracle/product/12.1.0/xe/bin/tnslsnr &"
su oracle -c "echo startup\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba"

echo "Starting setup"
echo

echo "Prepare sql scripts"

for f in $(ls script-sql/*); do
  echo "Updating sql file $f"
  case "$f" in
    script-sql/ORACLE_FUM_TABLE_CREATION.sql)   echo "Updating sql file $f"; \
                                                cat $f \
                                                | sed -e "s%ACCEPT LOGDIR%DEFINE LOGDIR = . --%" \
                                                | sed -e "s%ACCEPT TS_DATA%DEFINE TS_DATA = $DB_TS --%" \
                                                | sed -e "s%ACCEPT TS_INDEX%DEFINE TS_INDEX = $DB_TS --%" \
                                                > setup/0002.create.database.as.user.sql; \
                                                head -21 setup/0002.create.database.as.user.sql;;
    script-sql/ORACLE_FUM_TABLE_INSERT.sql)     echo "Updating sql file $f"; \
                                                cat $f \
                                                | sed -e "s%ACCEPT LOGDIR%DEFINE LOGDIR = . --%" \
                                                > setup/0003.insert.database.as.user.sql; \
                                                head -21 setup/0003.insert.database.as.user.sql;; 
    script-sql/FUM_Creation_Oracle.sql)         echo "Updating sql file $f"; \
                                                cat $f \
                                                | sed -e "s%DEFINE TS_DATA = &1%DEFINE TS_DATA = $DB_TS%" \
                                                | sed -e "s%DEFINE TS_INDEX = &2%DEFINE TS_INDEX = $DB_TS%" \
                                                > setup/0002.create.database.as.user.sql; \
                                                head -21 setup/0002.create.database.as.user.sql;;
    *)                                          echo "Ignoring sql file $f";;                            
  esac
  echo                            
done

for f in $(ls setup/*); do
  case "$f" in
    *.sh)       echo "[SETUP] $0: running $f"; source "$f" ;;
    *.root.sql) echo "[SETUP] $0: running $f as root"; sqlplus -silent sys/oracle as sysdba @$(pwd)/$f $DB_USER $DB_PWD $DB_TS ;;
    *.user.sql) echo "[SETUP] $0: running $f as user"; sqlplus -silent $DB_USER/$DB_PWD @$(pwd)/$f ;;
    *)          echo "[SETUP] $0: ignoring $f" ;;
  esac
  echo
done

echo "Setup finished"
echo

# Gracefully shutdown
echo "Shutdown"
trap "su oracle -c 'echo shutdown immediate\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba'" INT TERM
