# Pull base image
# ---------------
FROM {{deps.database.name}} as base


# Maintainer
# ----------
LABEL maintainer "Emmanuel MESSEGUE <emmanuel.messegue@fircosoft.com>"


# Environment that need to be set outside dockerfle before building.
# Variables available on container
# ----------
ENV SQL_MAIN_VERSION_PRODUCT=Continuity
ENV SQL_MAIN_VERSION={{deps.sql-main-sqlserver.version}}
ENV DB_USERNAME="continuity"
ENV DB_PASSWORD="hello00"
ENV DB_NAME="continuitydb"


# Copy reference files to trigger rebuild upon change
# ----------
USER root
COPY {{imageDataPath}} /imageData


# Copy project init scripts
# ----------
USER root
RUN echo Copying {{deps.sql-main-sqlserver.installpath}}/Continuity_*_Creation_SqlServer.sql in $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/0002.create.database.as.user.sql
COPY {{deps.sql-main-sqlserver.installpath}}/Continuity_*_Creation_SqlServer.sql $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/0002.create.database.as.user.sql


# # Custom script to check db health and readyness
# # ----------
# COPY ./checkDBStatusCustom.sh $ORACLE_BASE
# ENV CHECK_DB_FILE="checkDBStatusCustom.sh"


# Run the base image init script
# ----------
RUN SA_PASSWORD=$SA_PASSWORD \
  DB_NAME=$DB_NAME \
  DB_USERNAME=$DB_USERNAME \
  DB_PASSWORD=$DB_PASSWORD \
  $FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT


# Run SQL Server as mssql user
# ----------
USER mssql


# # Healtchcheck command. 
# # Set interval to 30s instead of 1m in base image to get a first check after 30s and get a healthy status faster if possible.
# # ----------
# HEALTHCHECK --interval=30s --start-period=5m \
#    CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1
