#!/bin/bash

# Setup the coreengine
# ---------------
./setupCoreEngine.sh

# Setup the requester
# ---------------
./setupRequester.sh

# Setup the FILTER
# ---------------
./setupFilter.sh

# Chain the command
# ---------------
echo "Running the command : $1"
$*
