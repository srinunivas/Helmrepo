#!/bin/bash

# Default values
# ---------------
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE}")
CURRENT_PATH=$(dirname "${SCRIPT_PATH}")
DIR_NAME=`basename "$CURRENT_PATH"`
REFERENCES_PATH=$CURRENT_PATH/../../../references
IMAGE_DATA_PATH=./imageData
IMAGE_DATA_FILE=$IMAGE_DATA_PATH/imageData.json


# Script usage
# ---------------
usage() {
  cat << EOF

Usage: buildDockerImageFromDependencies.sh [--imageData imageData]
Builds a Docker Image for Example-MyComponentB.
  
Parameters:
   --imageData : Image data file with all dependencies. Default value : imageData.json

EOF

}


# Process the script parameters
# ---------------
while getopts "ht:-:" optname; do
  case "$optname" in
    -)
      case "${OPTARG}" in
        imageData)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          IMAGE_DATA_FILE=$IMAGE_DATA_PATH/$val.json
          ;;
        imageData=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          IMAGE_DATA_FILE=$IMAGE_DATA_PATH/$val.json
          ;;
        *)
          echo "Unknown error while processing options inside buildDockerImageFromDependencies.sh"
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
      echo "Unknown error while processing options inside buildDockerImageFromDependencies.sh"
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


# Get image name
# ---------------
imageName=$(jq -r '.imageData.name' $IMAGE_DATA_FILE)


# Create artifacts and images references dirctories
# ---------------
[[ -d $IMAGE_DATA_PATH/images ]] && rm -rf $IMAGE_DATA_PATH/images
mkdir -p $IMAGE_DATA_PATH/images
[[ -d $IMAGE_DATA_PATH/artifacts ]] && rm -rf $IMAGE_DATA_PATH/artifacts
mkdir -p $IMAGE_DATA_PATH/artifacts

# Get filterengine reference data
# ---------------
componentBReference=$(jq -r '.imageData.dependencies[] | select(.name=="main" and .type=="artifact") | .reference' $IMAGE_DATA_FILE)
componentBReferenceFileName=$(find $REFERENCES_PATH/artifacts -name '*.json' -type f -exec grep -l '"name".*:.*"'$componentBReference {} \;)
if [[ -z "$componentBReferenceFileName" ]]; then
  echo Cannot find reference $componentBReference
  exit 2
fi
componentBReferenceUri=$(jq -r '.artifact.uri' $componentBReferenceFileName)
if [[ -z "$componentBReferenceUri" ]]; then
  echo Cannot find URI for $componentBReference
  exit 2
fi
mkdir -p "references/$componentBReference"
curl -SL "$componentBReferenceUri" | tar -xzC "references/$componentBReference"
cp $componentBReferenceFileName $IMAGE_DATA_PATH/artifacts


# Build the image
# ---------------
./buildDockerImage.sh \
  -t $imageName \
  --imageData $IMAGE_DATA_FILE \
  --uri $componentBReferenceUri


# Remove artifacts and images references dirctories
# ---------------
rm -rf $IMAGE_DATA_PATH/images
rm -rf $IMAGE_DATA_PATH/artifacts


# Exit with last command exit code
# ---------------
exit $?