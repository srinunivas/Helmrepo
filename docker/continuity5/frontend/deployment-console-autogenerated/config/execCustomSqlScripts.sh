#!/bin/bash

execSqlScript() {
case "$DB_VENDOR" in
  oracle)
    SQL_COMMAND="sqlplus $DB_USER/$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"
    echo "exit" | $SQL_COMMAND @"$1"
    ;;

  microsoft)
    JDBC_JAR=/opt/continuity/$MSSQL_JDBC_VERSION.jar
    SQL_COMMAND="sqlcmd -h-1 -S $DB_HOST,$DB_PORT -U $DB_USER -P $DB_PASSWORD -d $DB_NAME"
    $SQL_COMMAND -i "$1"
    ;;

  *)
    echo "Invalid DB_VENDOR value '$DB_VENDOR'"
    echo "Allow values are 'oracle' and 'microsoft'"
    exit 1
    ;;
esac
}


if [ -d "$CUSTOM_SQL_SCRIPTS" ] && [ -n "$(ls -A $CUSTOM_SQL_SCRIPTS)" ]; then
  echo "Executing custom sql scripts."
  for f in $(printf '%s ' $CUSTOM_SQL_SCRIPTS/*.sql | sort -zV); do
    echo "Running $f"; execSqlScript $f; echo
  done
  echo "Done."
else
  echo "No custom sql scripts found in $CUSTOM_SQL_SCRIPTS."
fi