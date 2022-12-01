#!/bin/bash

# Setup the coreengine
# ---------------
./setupCoreEngine.sh

# Setup the multiplexer
# ---------------
./setupDBClient.sh

# Chain the command
# ---------------
echo "Running the command : $1"
$*
