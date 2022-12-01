#!/bin/bash

# Setup the coreengine
# ---------------
./setupCoreEngine.sh

# Chain the command
# ---------------
echo "Running the command : $1"
$*
