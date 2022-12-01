#!/bin/env bash

# This script starts a new Docker container with EasySoft.
# All these containers share a volume for /usr/local/easysoft directory where the license is installed.
# This way you can update the license for all containers at once.

# If there is a newer version of the image (different digest) with an updated license
# then a new volume will be created.

export EASYSOFT_IMAGE=${1:-jenkins-deploy.fircosoft.net/third-parties/easysoft-proxy:3.8.0-centos7-oracle19.6}
export ODBC_DATASOURCE=${2:-TRUSTV5}
export TNSNAME_ADDRESS_NAME=${3:-ORA12}
export TNSNAME_SERVICE_NAME=${4:-PDBORCL}
export TNSNAME_HOSTNAME=${5:-10.55.63.3}
export TNSNAME_PORT=${6:-1521}
export DB_NAME=${7:-PDBORCL}
export DB_USERNAME=${8:-TRUSTV5}
export DB_PASSWORD=${9:-Hello00}

echo "Using Image ${EASYSOFT_IMAGE} with proxy"

docker run -ti --rm --add-host license.easysoft.com:127.0.0.1 --add-host ai.easysoft.com:127.0.0.1 -v /var/run/docker.sock:/var/run/docker.sock -e ODBC_DATASOURCE -e TNSNAME_ADDRESS_NAME -e TNSNAME_SERVICE_NAME -e TNSNAME_HOSTNAME -e TNSNAME_PORT -e DB_NAME -e DB_USERNAME -e DB_PASSWORD "${EASYSOFT_IMAGE}" bash
