#!/bin/bash

set -e

echo "Starting database"
lsnrctl start
echo startup\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba

head -21 $TRUST_DATABASE_HOME/setup/0002.create.database.as.user.sql

echo "Starting setup"
echo

for f in $(ls $TRUST_DATABASE_HOME/setup/*); do
  echo "found file $f"
  case "$f" in
    *.sh)
      echo "[SETUP] $0: running $f"; source "$f" ;;
    *.root.sql)
      echo "QUIT;" >> $f
      echo "[SETUP] $0: running $f as root"; sqlplus -silent sys/$ORACLE_PWD@$ORACLE_SID as sysdba @$f $DB_USER $DB_PWD $DB_TS ;;
    *.user.sql)
      echo "QUIT;" >> $f
      echo "[SETUP] $0: running $f as user"; sqlplus -silent $DB_USER/$DB_PWD@$ORACLE_SID @$f ;;
    *)
      echo "[SETUP] $0: ignoring $f" ;;
  esac
  echo
done

echo "Gracefully shutdown"
trap "echo shutdown immediate\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba" INT TERM
