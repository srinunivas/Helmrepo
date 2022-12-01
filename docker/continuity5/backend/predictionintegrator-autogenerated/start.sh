#!/bin/bash

# Setup the coreengine
# ---------------
./setupCoreEngine.sh

# Setup the predictionintegrator
# ---------------
./setupPredictionIntegrator.sh

# Chain the command
# ---------------
echo "Running the command : $1"
$*
