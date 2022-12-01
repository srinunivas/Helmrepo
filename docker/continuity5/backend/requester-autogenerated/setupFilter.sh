#!/bin/bash

# Copy the licence file
# ---------------
[[ ! -f $CONTINUITY_HOME/resources/$FILTER_PRODUCT/licence/fof.cf ]] && { echo "Error : licence file $CONTINUITY_HOME/resources/$FILTER_PRODUCT/licence/fof.cf not found." ; exit 1 ; }
cp $CONTINUITY_HOME/resources/$FILTER_PRODUCT/licence/fof.cf $CONTINUITY_HOME/backend/FilterEngine


# Copy the config files
# ---------------
if [ "$(ls -A $CONTINUITY_HOME/resources/$FILTER_PRODUCT/config)" ] 
then
    echo "Copying config from $CONTINUITY_HOME/resources/$FILTER_PRODUCT/config to $CONTINUITY_HOME/backend/FilterEngine"
    cp -r $CONTINUITY_HOME/resources/$FILTER_PRODUCT/config/. $CONTINUITY_HOME/backend/FilterEngine
else
    echo "Error : No conf. files found in $CONTINUITY_HOME/resources/$FILTER_PRODUCT/config"
    exit 1
fi
