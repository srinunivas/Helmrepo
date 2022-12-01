# Pull base image
# ---------------
FROM {{deps.database.name}} as base

# Pre-built oracle uses the following variables :
#    ORACLE_SID            = ORCLCDB
#    ORACLE_PDB            = ORCLPDB1
#    ORACLE_PWD            = Fircosoft00
#    ORACLE_CHARACTERSET   = AL32UTF8


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV SQL_MAIN_VERSION_PRODUCT=Continuity
ENV SQL_MAIN_VERSION={{deps.sql-main-oracle.version}}
ENV DB_USER_PWD=hello00
ENV DB_USER=continuity


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Copy "static" files
# ----------
USER oracle
RUN mkdir /home/oracle/sql
COPY ./sql/. /home/oracle/sql
COPY ./scripts/. $ORACLE_BASE/scripts


# Copy sql file to build continuity db user
# ----------
RUN echo Untarring {{deps.sql-main-oracle.uri}} in /home/oracle/sql/
RUN curl -SL {{deps.sql-main-oracle.uri}} | tar -xzC /home/oracle/sql


# Custom script to check db health and readyness
# ----------
COPY ./checkDBStatusCustom.sh $ORACLE_BASE
ENV CHECK_DB_FILE="checkDBStatusCustom.sh"


# Start the datserver, execute the statup scripts, then stop
# ----------
COPY ./runOracleCustom.sh $ORACLE_BASE
ENV RUN_FILE="runOracleCustom.sh"
RUN DOCKER_BUILD=1 $ORACLE_BASE/$RUN_FILE


# Healtchcheck command. 
# Set interval to 30s instead of 1m in base image to get a first check after 30s and get a healthy status faster if possible.
# ----------
HEALTHCHECK --interval=30s --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1
