#!/bin/bash

# Copy the licence file
# ---------------
MAJOR="$(cut -d'.' -f1 <<<"$FILTERENGINE_VERSION")"
MINOR="$(cut -d'.' -f2 <<<"$FILTERENGINE_VERSION")"
[[ ! -f $FILTER_HOME/resources/$FILTERENGINE_PRODUCT/licence/$MAJOR.$MINOR/fof.cf ]] && { echo "Error : licence file $FILTER_HOME/resources/$FILTERENGINE_PRODUCT/licence/$MAJOR.$MINOR/fof.cf not found." ; exit 1 ; }
cp $FILTER_HOME/resources/$FILTERENGINE_PRODUCT/licence/$MAJOR.$MINOR/fof.cf $FILTER_HOME/fof


# Copy the default conf files
# ---------------
for f in $FILTER_HOME/resources/$FILTERENGINE_PRODUCT/conf/default*; do
    [ -e "$f" ] && CONF_FILES_FOUND=true || CONF_FILES_FOUND=false
    break
done
if [ $CONF_FILES_FOUND ] ; then
    cp $FILTER_HOME/resources/$FILTERENGINE_PRODUCT/conf/default/* $FILTER_HOME/fof
else
    echo "Error : No conf. files found in $FILTER_HOME/resources/$FILTERENGINE_PRODUCT/conf/default."
    exit 1
fi


# Exec the command
echo "Running the command : $1"
$*
