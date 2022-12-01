#!/bin/bash

# Call original checkDBStatus.sh script
#---------------
$ORACLE_BASE/checkDBStatus.sh
ret=$?
[[ "$ret" != "0" ]] && exit $ret


# Don't check the modifications done in start files before it is needed.
#---------------
[[ ! -f ~/.checkStartUpModifications ]] && exit $ret

#check cty db creation
cat ~/.checkDbCreation

# Check it continuity is ready to use