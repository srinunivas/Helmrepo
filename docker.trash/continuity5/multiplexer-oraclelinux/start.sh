#!/bin/bash

# Copy the licence file
# ---------------
MAJOR="$(cut -d'.' -f1 <<<"$MULTIPLEXER_VERSION")"
MINOR="$(cut -d'.' -f2 <<<"$MULTIPLEXER_VERSION")"
[[ ! -f $CONTINUITY_HOME/resources/$MULTIPLEXER_PRODUCT/licence/$MAJOR.$MINOR/fbe.cf ]] && { echo "Error : licence file $CONTINUITY_HOME/resources/$MULTIPLEXER_PRODUCT/licence/$MAJOR.$MINOR/fof.cf not found." ; exit 1 ; }
cp $CONTINUITY_HOME/resources/$MULTIPLEXER_PRODUCT/licence/$MAJOR.$MINOR/fbe.cf $CONTINUITY_HOME/backend/conf

# Chain the command
# ---------------
echo "Running the command : $1"
$*
