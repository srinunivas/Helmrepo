#!/bin/bash

set -u

EASYSOFT_ENTRYPOINT="/opt/third-parties/easysoft/entrypoint.sh"
UNIXODBC_ENTRYPOINT="/opt/third-parties/unixodbc-oracle-client/entrypoint.sh"

if [[ -f $EASYSOFT_ENTRYPOINT ]]; then
  ENTRYPOINT=$EASYSOFT_ENTRYPOINT
else
  ENTRYPOINT=$UNIXODBC_ENTRYPOINT
fi

if [[ "$PRESET_ENV" = "true" ]]; then
  $ENTRYPOINT $@
  exit $?
fi

for bin in "FFFFEED" "FFFWDOG" "FFFXML" "MIGRATOR" "OFIDREP"; do
  if [[ "$@" = $bin* ]]; then
    $ENTRYPOINT $@
    exit $?
  fi
done

$@
exit $?
