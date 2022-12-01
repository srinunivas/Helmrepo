#!/bin/bash
RESOURCES=$CONTINUITY_HOME/resources

[[ ! -f $RESOURCES/fbe.cf ]] && { echo "Error : licence file $RESOURCES/fbe.cf not found." ; exit 1;}
cp $RESOURCES/fbe.cf $CONTINUITY_HOME/backend/conf/fbe.cf
echo "INFO: fbe.cf file has been copied"

if [ -z "$(ls -A $RESOURCES/filterData)" ]; then
    echo "WARN: filterData is empty"
else
    cp  $RESOURCES/filterData/* $CONTINUITY_HOME/backend/FilterEngine
    echo "INFO: filter data has been copied"
fi

if [ -f $RESOURCES/common_env.cfg ]; then
    cp $RESOURCES/common_env.cfg $CONTINUITY_HOME/backend;
    echo "INFO: common_env.cfg has been copied"
fi

if [ -f $RESOURCES/Requester.cfg ]; then
    cp $RESOURCES/Requester.cfg $CONTINUITY_HOME/backend/conf;
    echo "INFO: Requester.cfg has been copied"
fi

mkdir -p $CONTINUITY_HOME/backend/work/queues/internal.inject

cd $CONTINUITY_HOME/backend/ContinuityRequester

./Start_Requester.sh