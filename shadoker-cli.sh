#!/usr/bin/env bash
export GODEBUG="x509ignoreCN=0"
SCRIPT=$(readlink -f "$0")
PYTHONPATH="$(dirname "$SCRIPT")" PYTHONHASHSEED=0 DOCKER_BUILDKIT=1 python3 ./shadoker/__main__.py "$@"