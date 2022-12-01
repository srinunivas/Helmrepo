#!/bin/bash
set -eo pipefail

RESOURCES=$CONTINUITY_HOME/resources

[[ ! -f $RESOURCES/fbe.cf ]] && { echo "Error : licence file $RESOURCES/fbe.cf not found." ; exit 1;}
cp $RESOURCES/fbe.cf $CONTINUITY_HOME/backend/conf/fbe.cf
echo "INFO: fbe.cf file has been copied"

if [ -f $RESOURCES/common_env.cfg ]; then
    cp $RESOURCES/common_env.cfg $CONTINUITY_HOME/backend;
    echo "INFO: common_env.cfg has been copied"
fi

if [ -f $RESOURCES/Stripping.cfg ]; then
    cp $RESOURCES/Stripping.cfg $CONTINUITY_HOME/backend/conf;
    echo "INFO: Stripping.cfg has been copied"
fi

cd $CONTINUITY_HOME/backend/ContinuityStripping

if [ "$1" == "RuleRecorder" ]; then
  if [ -z "$(ls -A $RESOURCES/rules)" ]; then
         echo "WARN: Stripping rules folder is empty"
    else
        cp  $RESOURCES/rules/* $CONTINUITY_HOME/backend/work/rules/Stripping/in
        echo "INFO: Stripping rules has been copied"
    fi
    ./Start_StrippingRuleRecorder.sh
elif [ "$1" == "InternalFeeder" ]; then
    ./Start_StrippingInternalFeeder.sh
else
    ./Start_Stripping.sh
fi