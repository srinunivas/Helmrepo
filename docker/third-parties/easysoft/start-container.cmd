@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM This script starts a new Docker container with EasySoft.
REM All these containers share a volume for /usr/local/easysoft directory where the license is installed.
REM This way you can update the license for all containers at once.

REM If there is a newer version of the image (different digest) with an updated license
REM then a new volume will be created.

SET EASYSOFT_IMAGE=jenkins-deploy.fircosoft.net/third-parties/easysoft:3.5.1-centos7-oracle12.1
SET EASYSOFT_LICENSE_IMAGE=jenkins-deploy.fircosoft.net/third-parties/easysoft-licenses:1.0
SET ODBC_DATASOURCE=TRUSTV5
SET TNSNAME_ADDRESS_NAME=ORA12
SET TNSNAME_SERVICE_NAME=PDBORCL
SET TNSNAME_HOSTNAME=10.55.63.3
SET TNSNAME_PORT=1521
SET DB_NAME=PDBORCL
SET DB_USERNAME=TRUSTV5
SET DB_PASSWORD=Hello00

IF NOT "%1"=="" SET EASYSOFT_IMAGE=%1
IF NOT "%2"=="" SET ODBC_DATASOURCE=%2
IF NOT "%3"=="" SET TNSNAME_ADDRESS_NAME=%3
IF NOT "%4"=="" SET TNSNAME_SERVICE_NAME=%4
IF NOT "%5"=="" SET TNSNAME_HOSTNAME=%5
IF NOT "%6"=="" SET TNSNAME_PORT=%6
IF NOT "%7"=="" SET DB_NAME=%7
IF NOT "%8"=="" SET DB_USERNAME=%8
IF NOT "%9"=="" SET DB_PASSWORD=%9

ECHO Using Image "%EASYSOFT_IMAGE%" and License Image "%EASYSOFT_LICENSE_IMAGE%"

SET USE_VOLUME=1

IF [%USE_VOLUME%] == [1] (
  ECHO Get Digest, pulling image
  docker pull "%EASYSOFT_LICENSE_IMAGE%"
  SET GET_DIGEST_CMD=docker inspect --format="{{index .RepoDigests 0}}" "!EASYSOFT_LICENSE_IMAGE!"
  FOR /F "tokens=* USEBACKQ" %%F IN (`%GET_DIGEST_CMD%`) DO (
    SET DIGEST=%%F
  )
  IF [%DIGEST%] == [] (
    SET DIGEST=latest
  ) ELSE (
    SET DIGEST=%DIGEST:~7%
  )
  ECHO Digest is "!DIGEST!"

  SET EASYSOFT_VOLUME_NAME=easysoft-license-!DIGEST:~0,8!
  ECHO Volume name is "!EASYSOFT_VOLUME_NAME!"
  SET CHECK_VOLUME_CMD=docker volume ls -q --filter "name=!EASYSOFT_VOLUME_NAME!"
  FOR /F "tokens=* USEBACKQ" %%F IN (`%CHECK_VOLUME_CMD%`) DO (
    SET CURRENT_VOLUME=%%F
  )

  IF [%CURRENT_VOLUME%] == [] (
    ECHO Volume "!EASYSOFT_VOLUME_NAME!" not present, creating it
    docker run --rm -v "!EASYSOFT_VOLUME_NAME!":/opt/third-parties/easysoft/ "%EASYSOFT_LICENSE_IMAGE%"
  )

  ECHO Listing containers with volume "!EASYSOFT_VOLUME_NAME!"
  docker ps -a --filter "volume=!EASYSOFT_VOLUME_NAME!"

  REM In the container shell you can run '/usr/local/easysoft/license/licshell view' to check the EasySoft license
  docker run -ti --rm -v "!EASYSOFT_VOLUME_NAME!":/opt/third-parties/easysoft/ -e ODBC_DATASOURCE -e TNSNAME_ADDRESS_NAME -e TNSNAME_SERVICE_NAME -e TNSNAME_HOSTNAME -e TNSNAME_PORT -e DB_NAME -e DB_USERNAME -e DB_PASSWORD "%EASYSOFT_IMAGE%" bash
) ELSE (
  ECHO NO VOLUME here
  docker run -ti --rm -e ODBC_DATASOURCE -e TNSNAME_ADDRESS_NAME -e TNSNAME_SERVICE_NAME -e TNSNAME_HOSTNAME -e TNSNAME_PORT -e DB_NAME -e DB_USERNAME -e DB_PASSWORD "%EASYSOFT_IMAGE%" bash
)