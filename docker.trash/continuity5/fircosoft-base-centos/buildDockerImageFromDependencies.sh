#!/bin/bash

# Default values
# ---------------
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE}")
CURRENT_PATH=$(dirname "${SCRIPT_PATH}")
DIR_NAME=`basename "$CURRENT_PATH"`
REFERENCES_PATH=$CURRENT_PATH/../../references
IMAGE_DATA_PATH=./imageData
IMAGE_DATA_FILE=$IMAGE_DATA_PATH/imageData.json


# Script usage
# ---------------
usage() {
  cat << EOF

Usage: buildDockerImageFromDependencies.sh [--imageData imageData]
Builds a Docker Image for the CoreEngine.
  
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


# Get image name
# ---------------
imageName=$(jq -r '.imageData.name' $IMAGE_DATA_FILE)


# Create artifacts and images references dirctories
# ---------------
[[ -d $IMAGE_DATA_PATH/images ]] && rm -rf $IMAGE_DATA_PATH/images
mkdir -p $IMAGE_DATA_PATH/images
[[ -d $IMAGE_DATA_PATH/artifacts ]] && rm -rf $IMAGE_DATA_PATH/artifacts
mkdir -p $IMAGE_DATA_PATH/artifacts


# Get centos base reference data
# ---------------
centosReference=$(jq -r '.imageData.dependencies[] | select(.name=="centos" and .type=="image") | .reference' $IMAGE_DATA_FILE)
centosReferenceFileName=$(find $REFERENCES_PATH/images -name '*.json' -type f -exec grep -l '"name" : "'$centosReference {} \;)
centosReferenceBuildDate=$(jq -r '.image.buildDate' $centosReferenceFileName)
centosReferenceCommit=$(jq -r '.image.commit' $centosReferenceFileName)
centosReferenceName=$(jq -r '.image.name' $centosReferenceFileName)
cp $centosReferenceFileName $IMAGE_DATA_PATH/images


# Build the image
# ---------------
./buildDockerImage.sh \
  -t $imageName \
  --imageData $IMAGE_DATA_FILE \
  --centosImage $centosReferenceName


# Remove artifacts and images references dirctories
# ---------------
rm -rf $IMAGE_DATA_PATH/images
rm -rf $IMAGE_DATA_PATH/artifacts


# Exit with last command exit code
# ---------------
exit $?