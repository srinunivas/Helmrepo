#!/bin/bash

set -u

UNIXODBC_ENTRYPOINT="/opt/third-parties/unixodbc-oracle-client/entrypoint.sh"

if [[ "$PRESET_ENV" = "true" ]]; then
  $UNIXODBC_ENTRYPOINT $@
  exit $?
fi

for bin in "FFFDIOC" "FFFDIOM" "PMWDOG"; do
  if [[ "$@" = $bin* ]]; then
    $UNIXODBC_ENTRYPOINT $@
    exit $?
  fi
done

$@
exit $?
