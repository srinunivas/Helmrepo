#!/bin/bash

#echo on
#set -x

# SETUP-UP SCRIPTS ARE EXECUTED EACH TIME THE CONTAINER STARTS IN SEQUENCE

source /home/oracle/.bashrc

# Touching a file that will be checked during healthcheck to check db users only after this point forward
touch ~/.checkStartUpModifications
