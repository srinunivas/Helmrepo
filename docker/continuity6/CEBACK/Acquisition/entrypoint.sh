#!/bin/bash
RESOURCES=$CONTINUITY_HOME/resources

[[ ! -f $RESOURCES/fbe.cf ]] && { echo "Error : licence file $RESOURCES/fbe.cf not found." ; exit 1;}
cp $RESOURCES/fbe.cf $CONTINUITY_HOME/backend/conf/fbe.cf
echo "INFO: fbe.cf file has been copied"

if [ -f $RESOURCES/common_env.cfg ]; then
    cp $RESOURCES/common_env.cfg $CONTINUITY_HOME/backend;
    echo "INFO: common_env.cfg has been copied"
fi

if [ -f $RESOURCES/Acquisition.cfg ]; then
    cp $RESOURCES/Acquisition.cfg $CONTINUITY_HOME/backend/conf;
    echo "INFO: Acquisition.cfg has been copied"
fi

cd $CONTINUITY_HOME/backend/ContinuityAcquisition

./Start_Acquisition.sh
