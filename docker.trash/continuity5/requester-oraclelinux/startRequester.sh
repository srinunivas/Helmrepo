#!/bin/bash
[[ -d $CONTINUITY_HOME/backend/FilterEngine ]] \
    && sudo chown -R continuity:fircosoft $CONTINUITY_HOME/backend/FilterEngine \
    || { echo "FilterEngine not found in $CONTINUITY_HOME/backend/FilterEngine" ; exit 1 ; }
cd $CONTINUITY_HOME/backend/ContinuityRequester
./Start_Requester.sh