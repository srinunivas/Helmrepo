#!/bin/bash

set -u

echo "Creating tnsnames.ora file"
echo "
$TNSNAME_ADDRESS_NAME =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = $TNSNAME_HOSTNAME)(PORT = $TNSNAME_PORT))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = $TNSNAME_SERVICE_NAME)
    )
  )
" > ~/tnsnames.ora

export TNS_ADMIN=$HOME

echo "Creating ~/.odbc.ini file"
echo "
[$ODBC_DATASOURCE]
Driver = ${ODBC_DRIVER:-ORACLE32}
Database = $DB_NAME
ServerName = $TNSNAME_SERVICE_NAME
User = $DB_USERNAME
Password = $DB_PASSWORD
METADATA_ID = 0
ENABLE_USER_CATALOG = 1
ENABLE_SYNONYMS = 1
" > ~/.odbc.ini

echo "Running $@"
$@
