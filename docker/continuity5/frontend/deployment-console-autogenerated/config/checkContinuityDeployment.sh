#!/bin/bash

deployContinuity() {
    javaVersion=`java -version 2>&1 | grep -i version | cut -d'"' -f2 | cut -d'.' -f1-2`
    if [ $javaVersion == "11.0" ]; then
      java -Djdbc.driver="$DB_DRIVER" -Djdbc.url="$DB_URL" -Djdbc.username=$DB_USER -Djdbc.password=$DB_PASSWORD -cp "$JDBC_JAR:/opt/continuity/deployment-console-${frontEndVersion}.jar" com.fircosoft.console.DeploymentConsole /opt/continuity/Continuity-${frontEndVersion}.jar
    else
      java -Xbootclasspath/a:"$JDBC_JAR" -Djdbc.driver="$DB_DRIVER" -Djdbc.url="$DB_URL" -Djdbc.username=$DB_USER -Djdbc.password=$DB_PASSWORD -Dlog.level=INFO -jar "/opt/continuity/deployment-console-${frontEndVersion}.jar" /opt/continuity/Continuity-${frontEndVersion}.jar
    fi
}

frontEndVersion=${FRONTEND_VERSION/"release-"/""}
frontEndVersion=${frontEndVersion/"develop-"/""}

# Get the version deployed in the db
case "$DB_VENDOR" in
  oracle)
    DB_DRIVER="oracle.jdbc.OracleDriver"
    DB_URL="jdbc:oracle:thin:@$DB_HOST:$DB_PORT/$DB_NAME"
    JDBC_JAR=/opt/continuity/$ORACLE_JDBC_VERSION.jar
    deployedVersion=`sqlplus -s $DB_USER/$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME << EOF
SET PAGESIZE 0
SET FEEDBACK OFF
SELECT version FROM firco_wkf_applications WHERE label = 'Firco Continuity';
EXIT 
EOF`
    ;;

  microsoft)
    DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
    DB_URL="jdbc:sqlserver://$DB_HOST:$DB_PORT;databaseName=$DB_NAME;"
    JDBC_JAR=/opt/continuity/$MSSQL_JDBC_VERSION.jar
    deployedVersion=`sqlcmd -h-1 -S $DB_HOST,$DB_PORT -U $DB_USER -P $DB_PASSWORD -d $DB_NAME -Q "SET NOCOUNT ON; SELECT version FROM firco_wkf_applications WHERE label = 'Firco Continuity';"`
    ;;

  *)
    echo "Invalid DB_VENDOR value '$DB_VENDOR'"
    echo "Allow values are 'oracle' and 'microsoft'"
    exit 1
    ;;
esac

# Check if no version is deployed
if [ -z "${deployedVersion}" ]; then
    echo "No front-end version found in db $DB_USER"
    echo "Deploying ${frontEndVersion}."
    deployContinuity
    echo "Done."
    return
fi

# Do nothing if same version is already deployed
if [ $deployedVersion == ${frontEndVersion} ]; then
    echo "Front-end version ${frontEndVersion} is already deployed in db $DB_USER"
    echo "Doing nothing."
    echo "Done."
    return
fi

# Check if another version is deployed
if [ ! -z "${deployedVersion}" ]; then
    echo "Front-end version ${deployedVersion} is already deployed in db $DB_USER"
    echo "Deploying ${frontEndVersion} over it."
    deployContinuity
    echo "Done."
    return
fi
