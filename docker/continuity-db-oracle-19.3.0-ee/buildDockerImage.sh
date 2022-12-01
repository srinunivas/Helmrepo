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

Usage: buildDockerImage.sh [-t image-name] --imageData imageData --oracleImage oracleImage --sqlMainUri sqlMainUri --sqlMainVersion sqlMainVersion --sqlBusinessObjectsUri sqlBusinessObjectsUri --sqlBusinessObjectsVersion sqlBusinessObjectsVersion 
Builds a Docker Image for Oracle Database.
  
Parameters:
   -t                 : tags the docker image with image-name. Default value is the name of the containing directory.
   --imageData          : Image data file with all dependencies
   --oracleImage               : oracle image to start from
   --sqlMainUri                : full uri of the main product sql artifact
   --sqlMainVersion            : main product db version
   --sqlMainUri                : full uri of the business objects sql artifact
   --sqlBusinessObjectsVersion : advanced reporting db version

EOF

}


# Process the script parameters
# ---------------
while getopts "ht:-:" optname; do
  case "$optname" in
    -)
      case "${OPTARG}" in
        oracleImage)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          ORACLE_IMAGE=$val
          ;;
        oracleImage=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          ORACLE_IMAGE=$val
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
        sqlMainUri)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_MAIN_URI=$val
          ;;
        sqlMainUri=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_MAIN_URI=$val
          ;;
        sqlMainVersion)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_MAIN_VERSION=$val
          ;;
        sqlMainVersion=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_MAIN_VERSION=$val
          ;;
        sqlBusinessObjectsUri)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_BUSINESS_OBJECTS_URI=$val
          ;;
        sqlBusinessObjectsUri=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_BUSINESS_OBJECTS_URI=$val
          ;;
        sqlBusinessObjectsVersion)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_BUSINESS_OBJECTS_VERSION=$val
          ;;
        sqlBusinessObjectsVersion=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          SQL_BUSINESS_OBJECTS_VERSION=$val
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
[[ "$ORACLE_IMAGE" = "" ]] && { usage ; exit 1 ; }
[[ "$IMAGE_DATA_FILE" = "" ]] && { usage ; exit 1 ; }
[[ "$SQL_MAIN_URI" = "" ]] && { usage ; exit 1 ; }
[[ "$SQL_MAIN_VERSION" = "" ]] && { usage ; exit 1 ; }
[[ "$SQL_BUSINESS_OBJECTS_URI" = "" ]] && { usage ; exit 1 ; }
[[ "$SQL_BUSINESS_OBJECTS_VERSION" = "" ]] && { usage ; exit 1 ; }


# Compute image name
# ---------------
[[ "$IMAGE_NAME" = "" ]] && IMAGE_NAME=$DIR_NAME:$SQL_MAIN_VERSION-$SQL_BUSINESS_OBJECTS_VERSION


# Build the docker image
# ---------------
docker build . \
  -t $IMAGE_NAME \
  --build-arg ORACLE_IMAGE=$ORACLE_IMAGE \
  --build-arg IMAGE_DATA_FILE=$IMAGE_DATA_FILE \
  --build-arg SQL_MAIN_URI=$SQL_MAIN_URI \
  --build-arg SQL_MAIN_VERSION=$SQL_MAIN_VERSION \
  --build-arg SQL_BUSINESS_OBJECTS_URI=$SQL_BUSINESS_OBJECTS_URI \
  --build-arg SQL_BUSINESS_OBJECTS_VERSION=$SQL_BUSINESS_OBJECTS_VERSION


# Push the image in central repository
# ---------------
docker push $IMAGE_NAME


# Exit with last command exit code
# ---------------
exit $?