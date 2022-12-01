FROM mcr.microsoft.com/mssql/server:{{version}}

LABEL net.fircosoft.image.name="SQL Server"
LABEL net.fircosoft.image.product="{{product}}"
LABEL net.fircosoft.image.asset="{{asset}}"
LABEL net.fircosoft.image.component="{{component}}"
LABEL net.fircosoft.image.version="{{version}}"

# SQL Server variables
ENV MSSQL_COLLATION="SQL_Latin1_General_CP1_CI_AS"
ENV SA_PASSWORD="Hello00123"
ENV ACCEPT_EULA="Y"

# Image variables
ENV PATH="/opt/mssql-tools/bin:$PATH"
ENV FIRCOSOFT_DOCKER_HOME="/opt/fircosoft/sqlserver"
ENV FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR="$FIRCOSOFT_DOCKER_HOME/setup/scripts"
ENV FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT="$FIRCOSOFT_DOCKER_HOME/setup/init.sh"

# Product variables
ENV DB_USERNAME="firco"
ENV DB_PASSWORD="hello00"
ENV DB_NAME="fircodb"

# Install sudo and curl
USER root
RUN apt-get update \
  && apt-get install -y sudo curl \
  && rm -rf /var/lib/apt/lists/*

# Install image files
COPY setup $FIRCOSOFT_DOCKER_HOME/setup
RUN chmod +x $FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT

# Set mssql as default user
USER mssql
