#!/bin/bash

# Setup the coreengine
# ---------------
./setupCoreEngine.sh

# Setup the multiplexer
# ---------------
./setupMultiplexer.sh

# Chain the command
# ---------------
echo "Running the command : $1"
$*
