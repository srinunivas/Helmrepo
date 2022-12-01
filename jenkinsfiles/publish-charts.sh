#!/usr/bin/env bash

CHART_FILE=$1
PUBLISH_URL=$2
PUBLISH_AUTH=$3
BUILD_SUFFIX=$4

if [ -z "$PUBLISH_URL" ]
then
  echo Missing second argument PUBLISH_URL 
  exit 1
fi
if [ -z "$PUBLISH_AUTH" ]
then
  echo Missing third argument PUBLISH_AUTH
  exit 1
fi

while IFS="" read -r P || [ -n "$P" ]
do
  IFS=',' read -ra TOKEN <<< "$P"
  CHART_NAME=${TOKEN[0]}
  CHART_VERSION=${TOKEN[1]}
  CHART_PRODUCT=${TOKEN[2]}
  CHART_PRODUCT_VERSION=${TOKEN[3]}
  CHART_FOLDER=${TOKEN[4]}
  CHART_PUBLISH_DIR=${CHART_PRODUCT^}-k8s
  echo "PUBLISHING $CHART_FOLDER"
  pushd "$CHART_FOLDER" >/dev/null || exit 1
  PACKAGE_URL=$PUBLISH_URL/${CHART_PUBLISH_DIR}/$CHART_PRODUCT_VERSION/$CHART_NAME@$CHART_VERSION$BUILD_SUFFIX
  find . -type f -exec sh -c "echo {} | cut -c 3- | xargs -I % curl -fL -X PUT '${PACKAGE_URL}/%' --user '$PUBLISH_AUTH' -H 'Content-Type: application/octet-stream' --data-binary '@%'" \;

  { echo "chart=$CHART_NAME"; 
    echo "chartVersion=$CHART_VERSION";
    echo "product=$CHART_PRODUCT";
    echo "version=$CHART_PRODUCT_VERSION";
    echo "buildNum=$BUILD_SUFFIX";
    echo "url=$PACKAGE_URL"; } > build.properties

  curl -fvL --user jenkins-cd:747bc3ce03ea9a81626de8afc533289c "${JENKINS_URL}job/${CHART_PUBLISH_DIR}-promote/build" -F file0=@build.properties -F json='{"parameter": [{"name": "build.properties", "file": "file0"}]}'

  popd >/dev/null || exit 1
done < "$CHART_FILE"