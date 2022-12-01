#!/bin/sh

cat <<EOF

*****************************************************************************
Case Manager API SOAP Server Mock docker documentation: Here is some useful information.

- The package is unzipped under /opt/cty-backend.
- The standard start script (/opt/cty-backend/CMAPISoapServerMock/Start_CMAPISoapServerMock.sh)
  is used to launch the Case Manager API SOAP Server Mock program.
- You can replace any file or directory via "-v (or --volume)". (true for any docker)

Docker run command example:
    $ docker run \\
      -v /tmp/my-soapserver-config.properties:/opt/cty-backend/conf/CMAPISoapServerMock.properties \\
      -v /tmp/backend-log:/opt/cty-backend/log \\
      -it --hostname cmapi-soapserver-host --name cmapi-soap-server --rm \\
      jenkins-deploy.fircosoft.net/continuity6/cty-cmapi-soap-server-mock:master

*****************************************************************************

EOF

if [[ "$1" == "" ]]; then
  echo "================================================="
  echo "Invoking the CMAPI SOAP Server Mock start script:"
  echo "================================================="
  cd /opt/cty-backend/CMAPISoapServerMock
  ./Start_CMAPISoapServerMock.sh
else
  echo "==========================================="
  echo "Executing the following: $@"
  echo "==========================================="
  $@
fi
