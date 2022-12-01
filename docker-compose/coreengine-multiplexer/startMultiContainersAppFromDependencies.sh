#!/bin/bash

# Default values
# ---------------
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE}")
CURRENT_PATH=$(dirname "${SCRIPT_PATH}")
DIR_NAME=`basename "$CURRENT_PATH"`
REFERENCES_PATH=$CURRENT_PATH/../../references
APP_DATA_PATH=./appData
APP_DATA_FILE=$APP_DATA_PATH/appData.json


# Script usage
# ---------------
usage() {
  cat << EOF

Usage: startMultiContainersAppFromDependencies.sh [--appData appData]
Builds a Docker Image for the CoreEngine.
  
Parameters:
   --appData : Application data file with all dependencies. Default value : appData.json

EOF

}


# Process the script parameters
# ---------------
while getopts "ht:-:" optname; do
  case "$optname" in
    -)
      case "${OPTARG}" in
        appData)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          APP_DATA_FILE=$APP_DATA_PATH/$val.json
          ;;
        appData=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          APP_DATA_FILE=$APP_DATA_PATH/$val.json
          ;;
        *)
          echo "Unknown error while processing options inside startMultiContainersAppFromDependencies.sh"
          usage
          exit 1;
          ;;
      esac
      ;;
    "h")
      usage
      exit 0;
      ;;
    "?")
      usage;
      exit 1;
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside startMultiContainersAppFromDependencies.sh"
      usage
      exit 1;
      ;;
  esac
done


# Fails if there is more params in cmd line
# ---------------
shift $(expr $OPTIND - 1 )
if [ $# -gt 0 ]; then
    usage
    exit 1
fi


# Get app name
# ---------------
appName=$(jq -r '.appData.name' $APP_DATA_FILE)


# Get filterengine reference data
# ---------------
filterengineReference=$(jq -r '.appData.dependencies[] | select(.name=="filterengine" and .type=="image") | .reference' $APP_DATA_FILE)
filterengineReferenceFileName=$(find $REFERENCES_PATH/images -name '*.json' -type f -exec grep -l '"name" : "'$filterengineReference {} \;)
filterengineReferenceBuildDate=$(jq -r '.image.buildDate' $filterengineReferenceFileName)
filterengineReferenceCommit=$(jq -r '.image.commit' $filterengineReferenceFileName)
filterengineReferenceName=$(jq -r '.image.name' $filterengineReferenceFileName)


# Get coreengine reference data
# ---------------
coreengineReference=$(jq -r '.appData.dependencies[] | select(.name=="coreengine" and .type=="image") | .reference' $APP_DATA_FILE)
coreengineReferenceFileName=$(find $REFERENCES_PATH/images -name '*.json' -type f -exec grep -l '"name" : "'$coreengineReference {} \;)
coreengineReferenceBuildDate=$(jq -r '.image.buildDate' $coreengineReferenceFileName)
coreengineReferenceCommit=$(jq -r '.image.commit' $coreengineReferenceFileName)
coreengineReferenceName=$(jq -r '.image.name' $coreengineReferenceFileName)


# Get multiplexer reference data
# ---------------
multiplexerReference=$(jq -r '.appData.dependencies[] | select(.name=="multiplexer" and .type=="image") | .reference' $APP_DATA_FILE)
multiplexerReferenceFileName=$(find $REFERENCES_PATH/images -name '*.json' -type f -exec grep -l '"name" : "'$multiplexerReference {} \;)
multiplexerReferenceBuildDate=$(jq -r '.image.buildDate' $multiplexerReferenceFileName)
multiplexerReferenceCommit=$(jq -r '.image.commit' $multiplexerReferenceFileName)
multiplexerReferenceName=$(jq -r '.image.name' $multiplexerReferenceFileName)


# Get requester reference data
# ---------------
requesterReference=$(jq -r '.appData.dependencies[] | select(.name=="requester" and .type=="image") | .reference' $APP_DATA_FILE)
requesterReferenceFileName=$(find $REFERENCES_PATH/images -name '*.json' -type f -exec grep -l '"name" : "'$requesterReference {} \;)
requesterReferenceBuildDate=$(jq -r '.image.buildDate' $requesterReferenceFileName)
requesterReferenceCommit=$(jq -r '.image.commit' $requesterReferenceFileName)
requesterReferenceName=$(jq -r '.image.name' $requesterReferenceFileName)


# Exec the main service
# ---------------
./startMultiContainersApp.sh \
  --filterengineImage $filterengineReferenceName \
  --coreengineImage $coreengineReferenceName \
  --multiplexerImage $multiplexerReferenceName \
  --requesterImage $requesterReferenceName


# Exit with last command exit code
# ---------------
exit $?