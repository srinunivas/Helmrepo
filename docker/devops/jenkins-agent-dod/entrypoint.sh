#!/bin/sh

set -e

if [ $# -gt 0 ]
then
  exec java ${JAVA_OPTS:-} -jar "${JENKINS_SWARM_JAR}" -fsroot "$AGENT_WORKDIR" "$@"
fi

exec "$@"
