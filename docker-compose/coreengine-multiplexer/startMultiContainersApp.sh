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

Usage: startMultiContainersApp.sh --filterengineImage filterengineImage --coreengineImage coreengineImage --multiplexerImage multiplexerImage --requesterImage requesterImage
Starts a multiplexer in a docker container.
  
Parameters:
   --filterengineImage  : specifies the name of the FilterEngine docker image to use in the app
   --coreengineImage  : specifies the name of the CoreEngine docker image to use in the app
   --multiplexerImage : specifies the name of the Multiplexer docker image to user in the app
   --requesterImage : specifies the name of the Requester docker image to user in the app

EOF

}


# Process the script parameters
# ---------------
while getopts "h:-:" optname; do
  case "$optname" in
    -)
      case "${OPTARG}" in
        filterengineImage)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FILTERENGINE_IMAGE=$val
          ;;
        filterengineImage=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          FILTERENGINE_IMAGE=$val
          ;;
        coreengineImage)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          COREENGINE_IMAGE=$val
          ;;
        coreengineImage=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          COREENGINE_IMAGE=$val
          ;;
        multiplexerImage)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          MULTIPLEXER_IMAGE=$val
          ;;
        multiplexerImage=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          MULTIPLEXER_IMAGE=$val
          ;;
        requesterImage)
          val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          [[ "$val" = "" ]] && { usage ; exit 1; }
          REQUESTER_IMAGE=$val
          ;;
        requesterImage=*)
          val=${OPTARG#*=}
          [[ "$val" = "" ]] && { usage ; exit 1; }
          REQUESTER_IMAGE=$val
          ;;
        *)
          echo "Unknown error while processing options inside startMultiContainersApp.sh"
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
      echo "Unknown error while processing options inside startMultiContainersApp.sh"
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
[[ "$FILTERENGINE_IMAGE" = "" ]] && { usage ; exit 1 ; }
[[ "$COREENGINE_IMAGE" = "" ]] && { usage ; exit 1 ; }
[[ "$MULTIPLEXER_IMAGE" = "" ]] && { usage ; exit 1 ; }
[[ "$REQUESTER_IMAGE" = "" ]] && { usage ; exit 1 ; }


# Build .env file
# ---------------
[[ -f .env ]] && rm .env
echo -e "filterengineImage=$FILTERENGINE_IMAGE\n"    > .env
echo -e "coreengineImage=$COREENGINE_IMAGE\n"       >> .env
echo -e "multiplexerImage=$MULTIPLEXER_IMAGE\n"     >> .env
echo -e "requesterImage=$REQUESTER_IMAGE\n"         >> .env 


# Create log directory
# ---------------
[[ $CURRENT_PATH/log ]] && rm -rf $CURRENT_PATH/log
[[ ! -d $CURRENT_PATH/log ]] && { mkdir -p $CURRENT_PATH/log && chmod 777 -R $CURRENT_PATH/log ;  }
[[ ! -d $CURRENT_PATH/log/ContinuityMultiplexer/history ]] && { mkdir -p $CURRENT_PATH/log/ContinuityMultiplexer/history && chmod 777 -R $CURRENT_PATH/log/ContinuityMultiplexer ;  }
[[ ! -d $CURRENT_PATH/log/ContinuityRequester/history ]] && { mkdir -p $CURRENT_PATH/log/ContinuityRequester/history && chmod 777 -R $CURRENT_PATH/log/ContinuityRequester ;  }


# Start the application services
# ---------------
docker-compose up -d


# Exit with last command exit code
# ---------------
exit $?