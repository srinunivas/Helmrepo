#!/bin/bash

export CATALINA_OPTS="${CATALINA_OPTS} -Ddb.username=$DB_USER -Ddb.password=$DB_PASSWORD -Ddb.url=$DB_URL"

$CATALINA_HOME/bin/catalina.sh run