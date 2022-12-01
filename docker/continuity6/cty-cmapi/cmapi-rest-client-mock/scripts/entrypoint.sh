#!/bin/sh

cat <<EOF

*****************************************************************************
Case Manager API REST Client Mock docker documentation: Here is some useful information.

- The package is unzipped under /opt/cty-backend.
- The standard start script (/opt/cty-backend/CMAPIRestClientMock/Start_CMAPIRestClientMock.sh)
  is used to launch the Case Manager API REST Client Mock program.
- You can replace any file or directory via "-v (or --volume)". (true for any docker)

Docker run command example:
    $ docker run \\
      -v /tmp/my-restclient-config.properties:/opt/cty-backend/conf/CMAPIRestClientMock.properties \\
      -v /tmp/backend-log:/opt/cty-backend/log \\
      -it --hostname cmapi-restclient-host --name cmapi-rest-client --rm \\
      jenkins-deploy.fircosoft.net/continuity6/cty-cmapi-rest-client-mock:master

*****************************************************************************

EOF

if [[ "$1" == "" ]]; then
  echo "================================================="
  echo "Invoking the CMAPI REST Client Mock start script:"
  echo "================================================="
  cd /opt/cty-backend/CMAPIRestClientMock
  ./Start_CMAPIRestClientMock.sh
else
  echo "==========================================="
  echo "Executing the following: $@"
  echo "==========================================="
  $@
fi
