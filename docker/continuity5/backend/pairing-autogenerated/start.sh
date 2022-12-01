#!/bin/bash

# Setup the coreengine
# ---------------
./setupCoreEngine.sh

# Setup the pairing
# ---------------
./setupPairing.sh

# Chain the command
# ---------------
echo "Running the command : $1"
$*
