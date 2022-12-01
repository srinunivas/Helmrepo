FROM {{deps.sqlserver.name}}

# Database info
ENV DB_NAME=trustdb
ENV DB_USERNAME=trust
ENV DB_PASSWORD=hello00

# Use user root to setup database
USER root

# Copy project init scripts
COPY scripts/* $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/

RUN echo "Pulling {{deps.database.uri}}" \
  && curl -s {{deps.database.uri}} > $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/0002.create.database.as.user.sql \
  && head -21 $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/0002.create.database.as.user.sql

# Run the base image init script
RUN SA_PASSWORD=$SA_PASSWORD \
  DB_NAME=$DB_NAME \
  DB_USERNAME=$DB_USERNAME \
  DB_PASSWORD=$DB_PASSWORD \
  $FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT

# Run SQL Server as mssql user
USER mssql
