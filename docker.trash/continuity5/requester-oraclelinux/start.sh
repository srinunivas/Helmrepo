#!/bin/bash

# Copy the licence file
# ---------------
MAJOR="$(cut -d'.' -f1 <<<"$REQUESTER_VERSION")"
MINOR="$(cut -d'.' -f2 <<<"$REQUESTER_VERSION")"
[[ ! -f $CONTINUITY_HOME/resources/$REQUESTER_PRODUCT/licence/$MAJOR.$MINOR/fbe.cf ]] && { echo "Error : licence file $CONTINUITY_HOME/resources/$REQUESTER_PRODUCT/licence/$MAJOR.$MINOR/fof.cf not found." ; exit 1 ; }
cp $CONTINUITY_HOME/resources/$REQUESTER_PRODUCT/licence/$MAJOR.$MINOR/fbe.cf $CONTINUITY_HOME/backend/conf

# Chain the command
# ---------------
echo "Running the command : $1"
$*
