#!/bin/sh

cat <<EOF

*****************************************************************************
Case Manager API SOAP Client Mock docker documentation: Here is some useful information.

- The package is unzipped under /opt/cty-backend.
- The standard start script (/opt/cty-backend/CMAPISoapClientMock/Start_CMAPISoapClientMock.sh)
  is used to launch the Case Manager API SOAP Client Mock program.
- You can replace any file or directory via "-v (or --volume)". (true for any docker)

Docker run command example:
    $ docker run \\
      -v /tmp/my-soapclient-config.properties:/opt/cty-backend/conf/CMAPISoapClientMock.properties \\
      -v /tmp/backend-log:/opt/cty-backend/log \\
      -it --hostname cmapi-soapclient-host --name cmapi-soap-client --rm \\
      jenkins-deploy.fircosoft.net/continuity6/cty-cmapi-soap-client-mock:master

*****************************************************************************

EOF

if [[ "$1" == "" ]]; then
  echo "================================================="
  echo "Invoking the CMAPI SOAP Client Mock start script:"
  echo "================================================="
  cd /opt/cty-backend/CMAPISoapClientMock
  ./Start_CMAPISoapClientMock.sh
else
  echo "==========================================="
  echo "Executing the following: $@"
  echo "==========================================="
  $@
fi
