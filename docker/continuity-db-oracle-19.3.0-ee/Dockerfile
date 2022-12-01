# Pull base image
# ---------------
ARG ORACLE_IMAGE
FROM $ORACLE_IMAGE as base

# Pre-built oracle uses the following variables :
#    ORACLE_SID            = ORCLCDB
#    ORACLE_PDB            = ORCLPDB1
#    ORACLE_PWD            = Fircosoft00
#    ORACLE_CHARACTERSET   = AL32UTF8

# The image will create the db users at first execution of the container
# Continuity User     : CTY_${SQL_MAIN_VERSION//./_}
# Adv. Reporting User : ADV_REP_${SQL_BUSINESS_OBJECTS_VERSION//./_}
# Both users password : hello00


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


# Arguments that need to be set outside dockerfle before building
# Variables not available on container
# ----------
ARG IMAGE_DATA_FILE
ARG SQL_MAIN_URI
ARG SQL_MAIN_VERSION
ARG SQL_BUSINESS_OBJECTS_URI
ARG SQL_BUSINESS_OBJECTS_VERSION

RUN echo IMAGE_DATA_FILE=$IMAGE_DATA_FILE
RUN echo SQL_MAIN_URI=$SQL_MAIN_URI
RUN echo SQL_MAIN_VERSION=$SQL_MAIN_VERSION
RUN echo SQL_BUSINESS_OBJECTS_URI=$SQL_BUSINESS_OBJECTS_URI
RUN echo SQL_BUSINESS_OBJECTS_VERSION=$SQL_BUSINESS_OBJECTS_VERSION


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV SQL_MAIN_VERSION_PRODUCT=Continuity
ENV SQL_MAIN_VERSION=$SQL_MAIN_VERSION
ENV SQL_BUSINESS_OBJECTS_VERSION_PRODUCT=Continuity
ENV SQL_BUSINESS_OBJECTS_VERSION=$SQL_BUSINESS_OBJECTS_VERSION


# Copy reference files to trigger rebuild upon change
# ----------
USER root
RUN mkdir -p /imageData/images
RUN mkdir -p /imageData/artifacts
COPY $IMAGE_DATA_FILE          /imageData/imageData.json
COPY ./imageData/images/       /imageData/images/
COPY ./imageData/artifacts/    /imageData/artifacts/


# Copy "static" files
# ----------
USER oracle
RUN mkdir /home/oracle/sql
COPY ./sql/. /home/oracle/sql
COPY ./scripts/. $ORACLE_BASE/scripts


# Copy sql file to build continuity db user
# ----------
RUN echo Untarring $SQL_MAIN_URI in /home/oracle/sql
RUN curl -SL $SQL_MAIN_URI | tar -xzC /home/oracle/sql
RUN echo Untarring $SQL_BUSINESS_OBJECTS_URI in /home/oracle/sql
RUN curl -SL $SQL_BUSINESS_OBJECTS_URI | tar -xzC /home/oracle/sql


# Custom script to check db health and readyness
# ----------
COPY ./checkDBStatusCustom.sh $ORACLE_BASE
ENV CHECK_DB_FILE="checkDBStatusCustom.sh"


# Healtchcheck command. 
# Set interval to 30s instead of 1m in base image to get a first check after 30s and get a healthy status faster if possible.
# ----------
HEALTHCHECK --interval=30s --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1
