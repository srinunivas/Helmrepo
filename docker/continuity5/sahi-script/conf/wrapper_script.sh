#!/bin/bash
# Passing the url to the parameter file
sed -i "s+urlVar+$1+g" /sahi_pro_911/userdata/scripts/suite/nr/parameters.sah

# Start the sahi engine
./start_sahi.sh </dev/null &>/dev/null &  
sleep 10
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start sahi: $status"
  exit $status
fi

# Start tests
./testrunner.sh suite/nr/suite.suite $1 firefoxHL
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start tests: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

    while sleep 60; do
    ps aux |grep start_sahi.sh |grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux |grep testrunner.sh |grep -q -v grep
    PROCESS_2_STATUS=$?
    # If the greps above find anything, they exit with 0 status
    # If they are not both 0, then something is wrong
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
        echo "One of the processes has already exited."
        exit 1
    fi
    done
