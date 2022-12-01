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

if [ -f $RESOURCES/DecisionReapplication.cfg ]; then
    cp $RESOURCES/DecisionReapplication.cfg $CONTINUITY_HOME/backend/conf;
    echo "INFO: DecisionReapplication.cfg has been copied"
fi

cd $CONTINUITY_HOME/backend/ContinuityDecisionReapplication

if [ "$1" == "RuleRecorder" ]; then
    if [ -z "$(ls -A $RESOURCES/rules)" ]; then
         echo "WARN: DecisionReapplication rules folder is empty"
    else
        cp  $RESOURCES/rules/* $CONTINUITY_HOME/backend/work/rules/DecisionReapplication/in
        echo "INFO: DecisionReapplication rules has been copied"
    fi
    ./Start_DecisionReapplicationRuleRecorder.sh
else
    ./Start_DecisionReapplication.sh
fi