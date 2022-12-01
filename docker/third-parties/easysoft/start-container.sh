#!/bin/env bash

# This script starts a new Docker container with EasySoft.
# All these containers share a volume for /usr/local/easysoft directory where the license is installed.
# This way you can update the license for all containers at once.

# If there is a newer version of the image (different digest) with an updated license
# then a new volume will be created.

export EASYSOFT_LICENSE_IMAGE=jenkins-deploy.fircosoft.net/third-parties/easysoft-licenses:1.0
export EASYSOFT_IMAGE=${1:-jenkins-deploy.fircosoft.net/third-parties/easysoft:3.5.1-centos7-oracle12.1}
export ODBC_DATASOURCE=${2:-TRUSTV5}
export TNSNAME_ADDRESS_NAME=${3:-ORA12}
export TNSNAME_SERVICE_NAME=${4:-PDBORCL}
export TNSNAME_HOSTNAME=${5:-10.55.63.3}
export TNSNAME_PORT=${6:-1521}
export DB_NAME=${7:-PDBORCL}
export DB_USERNAME=${8:-TRUSTV5}
export DB_PASSWORD=${9:-Hello00}

export USE_VOLUME=1

echo "Using Image ${EASYSOFT_IMAGE} with license Image ${EASYSOFT_LICENSE_IMAGE}"

if [ "$USE_VOLUME" != 0 ]
then
  echo Get Digest, pulling image
  docker pull "${EASYSOFT_LICENSE_IMAGE}"

  DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "${EASYSOFT_LICENSE_IMAGE}" | sed -n -e 's/^.*sha256://p')
  echo "Digest is $DIGEST"

  EASYSOFT_VOLUME_NAME=easysoft-license-${DIGEST:0:8}

  CURRENT_VOLUME=$(docker volume ls -q --filter name="${EASYSOFT_VOLUME_NAME}")
  if [ -z "${CURRENT_VOLUME}" ]
  then
    echo "Volume ${EASYSOFT_VOLUME_NAME} not present, creating it"
    docker run --rm -v "${EASYSOFT_VOLUME_NAME}":/opt/third-parties/easysoft/ "${EASYSOFT_LICENSE_IMAGE}"
  else
    echo "Volume ${EASYSOFT_VOLUME_NAME} is present, listing containers"
    docker ps -a --filter volume="${EASYSOFT_VOLUME_NAME}"
  fi
# In the container shell you can run '/usr/local/easysoft/license/licshell view' to check the EasySoft license
  docker run -ti --rm -v "${EASYSOFT_VOLUME_NAME}":/opt/third-parties/easysoft/ -e ODBC_DATASOURCE -e TNSNAME_ADDRESS_NAME -e TNSNAME_SERVICE_NAME -e TNSNAME_HOSTNAME -e TNSNAME_PORT -e DB_NAME -e DB_USERNAME -e DB_PASSWORD "${EASYSOFT_IMAGE}" bash
else
  docker run -ti --rm -e ODBC_DATASOURCE -e TNSNAME_ADDRESS_NAME -e TNSNAME_SERVICE_NAME -e TNSNAME_HOSTNAME -e TNSNAME_PORT -e DB_NAME -e DB_USERNAME -e DB_PASSWORD "${EASYSOFT_IMAGE}" bash
fi