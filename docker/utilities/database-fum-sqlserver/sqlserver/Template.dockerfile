FROM {{deps.sqlserver.name}}

LABEL maintainer="David Thomé <david.thome@accuity.com>"

# Database info
ENV DB_NAME=FUM
ENV DB_USERNAME=FumLogin
ENV DB_PASSWORD=hello00

# Creation of folder scripts
USER root
RUN mkdir scripts/

# Unzip file from uri
# Take the .sql file from 'SQL-Server' folder 
# Rename them as create.database.as.user.sql file in order to be applied on FUM SQL Server db with init.sh
{{#deps.database.sqlScripts}}
COPY ["{{deps.database.installpath}}/{{creationScript}}", "$FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/0002.create.database.as.user.sql"]
{{/deps.database.sqlScripts}}


# Run the base image init script
RUN SA_PASSWORD=$SA_PASSWORD \	
  DB_NAME=$DB_NAME \
  DB_USERNAME=$DB_USERNAME \
  DB_PASSWORD=$DB_PASSWORD \
  $FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT

# Run SQL Server as mssql user
USER mssql