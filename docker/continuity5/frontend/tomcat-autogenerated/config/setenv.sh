# Set DB variables
#------------------
case "$DB_VENDOR" in
  oracle)
    JDBC_JAR=/usr/local/tomcat/lib/$ORACLE_JDBC_VERSION.jar
    ;;

  microsoft)
    JDBC_JAR=/usr/local/tomcat/lib/$MSSQL_JDBC_VERSION.jar
    ;;

  *)
    echo "Invalid DB_VENDOR value '$DB_VENDOR'"
    echo "Allow values are 'oracle' and 'microsoft'"
    exit 1
    ;;
esac

export CATALINA_OPTS="${CATALINA_OPTS} -DdbDriver='${DB_DRIVER}' -DdbUrl='${DB_URL}' -DdbUser=${DB_USER} -DdbPassword=${DB_PASSWORD} -Dfirco.log.dir=${CATALINA_HOME}/logs"

sed -i "s/continuity/$CONTEXT_NAME/g" /usr/local/tomcat/webapps/error.html
