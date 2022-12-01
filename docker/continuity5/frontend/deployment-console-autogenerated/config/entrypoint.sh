#!/bin/bash

set -e

# Deploy continuity into db
#------------------
source /opt/continuity/checkContinuityDeployment.sh

# Exec custom sql scripts
#------------------
source /opt/continuity/execCustomSqlScripts.sh
