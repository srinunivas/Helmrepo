# Pull base image
# ---------------
FROM {{deps.database.name}} as base

# Pre-built oracle uses the following variables :
#    ORACLE_SID            = ORCLCDB
#    ORACLE_PDB            = ORCLPDB1
#    ORACLE_PWD            = Fircosoft00
#    ORACLE_CHARACTERSET   = AL32UTF8

# The image will create the db users at first execution of the container
# Continuity User     : CTY_${SQL_ADVR_VERSION//./_}
# Continuity user password : hello00


# Maintainer
# ----------
LABEL maintainer "RBI-DL Fircosoft Continuity Paris <FircosoftContinuityParis@reedbusiness.com>"

# Get main information directly from imageData info
# -------------------------------------------------
LABEL product "{{product}}"
LABEL asset "{{asset}}"
LABEL version "{{version}}"

# Get push information directly from artifact
# -------------------------------------------
LABEL push "{{deps.sqladvr.push}}"

# Copy imageData configuration file
#  and dependencies configuration files in the image itself
# ---------------------------------------------------------
COPY {{imageDataPath}} /imageData


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV SQL_ADVR_VERSION_PRODUCT=Continuity
ENV SQL_ADVR_URI={{deps.sqladvr.uri}}
ENV SQL_ADVR_VERSION={{deps.sqladvr.version}}


# Copy "static" files
# ----------
USER oracle
RUN mkdir /home/oracle/sqladvr
RUN mkdir /home/oracle/sqlupdate
RUN mkdir /home/oracle/sqlhelpers
COPY ./sql/. /home/oracle/sqlhelpers
COPY ./scripts/. $ORACLE_BASE/scripts


# Copy sql file to build continuity db user
# ----------
COPY {{deps.sqladvr.installpath}}/* /home/oracle/sqladvr/

# Custom script to check db health and readyness
# ----------
COPY ./checkDBStatusCustom.sh $ORACLE_BASE
ENV CHECK_DB_FILE="checkDBStatusCustom.sh"


# Healtchcheck command. 
# Set interval to 30s instead of 1m in base image to get a first check after 30s and get a healthy status faster if possible.
# ----------
HEALTHCHECK --interval=30s --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1
