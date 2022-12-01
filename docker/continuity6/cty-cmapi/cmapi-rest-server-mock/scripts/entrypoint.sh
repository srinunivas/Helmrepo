#!/bin/sh

cat <<EOF

*****************************************************************************
Case Manager API REST Server Mock docker documentation: Here is some useful information.

- The package is unzipped under /opt/cty-backend.
- The standard start script (/opt/cty-backend/CMAPIRestServerMock/Start_CMAPIRestServerMock.sh)
  is used to launch the Case Manager API REST Server Mock program.
- You can replace any file or directory via "-v (or --volume)". (true for any docker)

Docker run command example:
    $ docker run \\
      -v /tmp/my-restserver-config.properties:/opt/cty-backend/conf/CMAPIRestServerMock.properties \\
      -v /tmp/backend-log:/opt/cty-backend/log \\
      -it --hostname cmapi-restserver-host --name cmapi-rest-server --rm \\
      jenkins-deploy.fircosoft.net/continuity6/cty-cmapi-rest-server-mock:master

*****************************************************************************

EOF

if [[ "$1" == "" ]]; then
  echo "================================================="
  echo "Invoking the CMAPI REST Server Mock start script:"
  echo "================================================="
  cd /opt/cty-backend/CMAPIRestServerMock
  ./Start_CMAPIRestServerMock.sh
else
  echo "==========================================="
  echo "Executing the following: $@"
  echo "==========================================="
  $@
fi
