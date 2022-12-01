#!/bin/bash

# Default values
# ---------------
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE}")
CURRENT_PATH=$(dirname "${SCRIPT_PATH}")
DIR_NAME=`basename "$CURRENT_PATH"`

# Script usage
# ---------------
usage() {
  cat << EOF

Usage: buildDockerImage.sh [-t image-name] --imageData imageData --fircosoftBaseImage fircosoftBaseImage --filterengineUri filterengineUri --filterengineVersion filterengineVersion
Builds a Docker Image for the CoreEngine.
  
Parameters:
   -t                     : tags the docker image with image-name. Default value is the name of the containing directory.
   --imageData          : Image data file with all dependencies
   --fircosoftBaseImage   : fircosoft base image to start from
   --filterengineUri      : full uri of the filterengine artifact
   --filterengineVersion  : filterengine version

EOF

}


# Process the script parameters
# ---------------
while getopts "ht:-:" optname; do
  case "$optname" in
    -)
      case "${OPTARG}" in
        fircosoftBaseImage)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FIRCOSOFT_BASE_IMAGE=$val
          ;;
        fircosoftBaseImage=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FIRCOSOFT_BASE_IMAGE=$val
          ;;
        imageData)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          IMAGE_DATA_FILE=$val
          ;;
        imageData=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          IMAGE_DATA_FILE=$val
          ;;
        filterengineUri)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FILTERENGINE_URI=$val
          ;;
        filterengineUri=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FILTERENGINE_URI=$val
          ;;
        filterengineVersion)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FILTERENGINE_VERSION=$val
          ;;
        filterengineVersion=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FILTERENGINE_VERSION=$val
          ;;
        *)
          echo "Unknown error while processing options inside buildDockerImage.sh"
          usage
          exit 1;
          ;;
      esac
      ;;
    "h")
      usage
      exit 0;
      ;;
    "t")
      IMAGE_NAME="$OPTARG"
      ;;
    "?")
      usage;
      exit 1;
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside buildDockerImage.sh"
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


# Check parameters
# ---------------
[[ "$FIRCOSOFT_BASE_IMAGE" = "" ]] && { usage ; exit 1 ; }
[[ "$IMAGE_DATA_FILE" = "" ]] && { usage ; exit 1 ; }
[[ "$FILTERENGINE_URI" = "" ]] && { usage ; exit 1 ; }
[[ "$FILTERENGINE_VERSION" = "" ]] && { usage ; exit 1 ; }


# Compute image name
# ---------------
[[ "$IMAGE_NAME" = "" ]] && IMAGE_NAME=$DIR_NAME:$FILTERENGINE_VERSION


# Build the docker image
# ---------------
docker build . \
  -t $IMAGE_NAME \
  --build-arg FIRCOSOFT_BASE_IMAGE=$FIRCOSOFT_BASE_IMAGE \
  --build-arg IMAGE_DATA_FILE=$IMAGE_DATA_FILE \
  --build-arg FILTERENGINE_URI=$FILTERENGINE_URI \
  --build-arg FILTERENGINE_VERSION=$FILTERENGINE_VERSION


# Push the image in central repository
# ---------------
docker push $IMAGE_NAME


# Exit with last command exit code
# ---------------
exit $?