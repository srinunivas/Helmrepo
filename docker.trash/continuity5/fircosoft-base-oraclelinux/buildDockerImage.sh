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

Usage: buildDockerImage.sh [-t image-name] --imageData imageData --oraclelinuxImage oraclelinuxImage
Builds a Fircosoft Base Image from a oraclelinux image.
  
Parameters:
   -t: tags the docker image with image-name. Default value is the name of the containing directory.
   --imageData          : Image data file with all dependencies
   --oraclelinuxImage   : oraclelinux base image to start from

EOF

}


# Process the script parameters
# ---------------
while getopts "ht:-:" optname; do
  case "$optname" in
    -)
      case "${OPTARG}" in
        oraclelinuxImage)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          ORACLELINUX_BASE_IMAGE=$val
          ;;
        oraclelinuxImage=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          ORACLELINUX_BASE_IMAGE=$val
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
[[ "$ORACLELINUX_BASE_IMAGE" = "" ]] && { usage ; exit 1 ; }
[[ "$IMAGE_DATA_FILE" = "" ]] && { usage ; exit 1 ; }


# Compute image name
# ---------------
[[ "$IMAGE_NAME" = "" ]] && IMAGE_NAME=$DIR_NAME


# Build the docker image
# ---------------
docker build . -t $IMAGE_NAME \
  --build-arg ORACLELINUX_BASE_IMAGE=$ORACLELINUX_BASE_IMAGE \
  --build-arg IMAGE_DATA_FILE=$IMAGE_DATA_FILE


# Push the image in central repository
# ---------------
docker push $IMAGE_NAME


# Exit with last command exit code
# ---------------
exit $?