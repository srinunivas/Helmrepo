#!/bin/bash

# Setup the coreengine
# ---------------
./setupCoreEngine.sh

# Setup the stripping
# ---------------
./setupStripping.sh

# Chain the command
# ---------------
echo "Running the command : $1"
$*
