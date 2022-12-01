#!/usr/bin/env bash

#echo NAME    : "$1"
#echo DIGEST  : "$2"
#echo DATE    : "$3"
#echo PRODUCT : "$4"
#echo ASSET   : "$5"
#echo VERSION : "$6"
#echo TAG_INFO: "$7"
#echo PLATFORM: "$8"
#echo ENV     : "$9"
#echo LABELS  : "$10"
#echo ----------

BUILD_PARAMS='{"parameter": ['
BUILD_PARAMS=$BUILD_PARAMS'{"name":"IMAGE", "value":"'$1'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"DIGEST", "value":"'$2'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"DATE", "value":"'$3'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"PRODUCT", "value":"'$4'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"ASSET", "value":"'$5'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"VERSION", "value":"'$6'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"TAG_INFO", "value":"'$7'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"PLATFORM", "value":"'$8'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"ENV", "value":"'$9'"},'
BUILD_PARAMS=$BUILD_PARAMS'{"name":"LABELS", "value":"'${10//\"/\\\"}'"}]}'
echo "BUILD_PARAMS=$BUILD_PARAMS"

# FPA JOB
# JOB=http://jenkins.fpa.rbxd.ds/view/all/job/E2E/job/portus-notification/build

# Jump JOB on FIRCOSOFT
JOB=http://jenkins.fircosoft.net/job/Deployment/job/e2e-notification/build
 
curl -vf -X POST "$JOB" \
  --user jenkins-cd:747bc3ce03ea9a81626de8afc533289c \
  --data-urlencode json="$BUILD_PARAMS"

