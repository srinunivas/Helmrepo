#!/bin/bash

# Copy the licence file
# ---------------
[[ ! -f $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/licence/fbe.cf ]] && { echo "Error : licence file $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/licence/fbe.cf not found." ; exit 1 ; }
cp $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/licence/fbe.cf $CONTINUITY_HOME/backend/conf

# Copy the config files
# ---------------
if [ "$(ls -A $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/config)" ] 
then
    echo "Copying external config from $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/config to $CONTINUITY_HOME/backend"
    cp -r $CONTINUITY_HOME/resources/$PAIRING_PRODUCT/config/. $CONTINUITY_HOME/backend
else
    echo "No external config provided."
fi
