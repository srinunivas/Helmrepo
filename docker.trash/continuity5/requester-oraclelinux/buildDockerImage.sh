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

Usage: buildDockerImage.sh [-t image-name] --imageData imageData --fircosoftBaseImage fircosoftBaseImage --requesterUri requesterUri --requesterVersion requesterVersion
Builds a Docker Image for the CoreEngine.
  
Parameters:
   -t                   : tags the docker image with image-name. Default value is the name of the containing directory.
   --imageData          : Image data file with all dependencies
   --fircosoftBaseImage : fircosoft base image to start from
   --requesterUri      : full uri of the requester artifact
   --requesterVersion  : requester version

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
        requesterUri)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          REQUESTER_URI=$val
          ;;
        requesterUri=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          REQUESTER_URI=$val
          ;;
        requesterVersion)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          REQUESTER_VERSION=$val
          ;;
        requesterVersion=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          REQUESTER_VERSION=$val
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
[[ "$REQUESTER_URI" = "" ]] && { usage ; exit 1 ; }
[[ "$REQUESTER_VERSION" = "" ]] && { usage ; exit 1 ; }


# Compute image name
# ---------------
[[ "$IMAGE_NAME" = "" ]] && IMAGE_NAME=$DIR_NAME:$REQUESTER_VERSION


# Build the docker image
# ---------------
docker build . \
  -t $IMAGE_NAME \
  --build-arg FIRCOSOFT_BASE_IMAGE=$FIRCOSOFT_BASE_IMAGE \
  --build-arg IMAGE_DATA_FILE=$IMAGE_DATA_FILE \
  --build-arg REQUESTER_URI=$REQUESTER_URI \
  --build-arg REQUESTER_VERSION=$REQUESTER_VERSION


# Push the image in central repository
# ---------------
docker push $IMAGE_NAME


# Exit with last command exit code
# ---------------
exit $?