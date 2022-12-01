# Microsoft SQL Server Docker Image

This is a Fircosoft base image for SQL Server based on official Microsoft
SQL Server image General Availability.

Some changes from the original image have been made:

- Two important variables have been added to simplify the image ceation:
  - `$FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR`: Used as the destination of your setup
    scripts
  - `$FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT`: Used to run the SQL Server database
    initialization.

  Please check the section bellow *Usage with Dockerfile*.

- The SQL Server binary path `/opt/mssql-tools/bin` has been added to the
  system environment variable `$PATH`. This means that you can run
  `sqlcmd` anywhere.

- Default SQL Server environments variables have been changed to follow the
  Fircosoft requirements. Please see the next section
  (*Default Environment $Variables*) to know more abour new default SQL Server
  environments variables.

Found the official SQL Server Docker documentation here:
https://hub.docker.com/_/microsoft-mssql-server

## Default Environment Variables

| Variable        | Default Value                   | Description                                                   |
|-----------------|---------------------------------|---------------------------------------------------------------|
| **SQL Server variables**                                                                                          |
| MSSQL_COLLATION | `SQL_Latin1_General_CP1_CI_AS`  | Default collation for SQL Server                              |
| SA_PASSWORD     | `Hello00123`                    | Database system administrator (userid = `'sa'`)               |
| ACCEPT_EULA     | `Y`                             | Confirms your acceptance of the End-User Licensing Agreement  |
| **Product variables**                                                                                             |
| DB_USERNAME     | `firco`                         | Your product database user name                               |
| DB_PASSWORD     | `hello00`                       | Your product database user password                           |
| DB_NAME         | `fircodb`                       | Your product database name                                    |

## Usage

```sh
# start database instance
docker run -i -p 1433:1433 jenkins-deploy.fircosoft.net/third-parties/sqlserver:<tag>

# sqlcmd usage
docker run -i --rm -v $(pwd):/src \
  jenkins-deploy.fircosoft.net/third-parties/sqlserver:<tag> \
  bash -c 'sqlcmd -S localhost -U $DB_USERNAME -P $DB_PASSWORD -d $DB_NAME -i /src/my-script.sql'
```

## Dockerfile usage

```dockerfile
FROM jenkins-deploy.fircosoft.net/third-parties/sqlserver:2019-GA-ubuntu-16.04

# Define usage database info
ENV DB_NAME=testdb
ENV DB_USERNAME=testuser
ENV DB_PASSWORD=hello00

# Use user root to setup database
USER root

# Copy your specific project init scripts (.sh & .sql)
COPY scripts/* $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/

RUN curl -s http://dev-nexus.fircosoft.net/service/local/repositories/site-builds/content/TrustSql/5.1.1.0.p1-release-master/FFF_5110_Single_Creation_SqlServer.sql \
  > $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/0002.create.database.as.user.sql \
  && head -21 $FIRCOSOFT_DOCKER_SETUP_SCRIPTS_DIR/0002.create.database.as.user.sql

# Run the base image init script
RUN SA_PASSWORD=$SA_PASSWORD \
  DB_NAME=$DB_NAME \
  DB_USERNAME=$DB_USERNAME \
  DB_PASSWORD=$DB_PASSWORD \
  $FIRCOSOFT_DOCKER_SETUP_INIT_SCRIPT

# Run SQL Server as mssql user
USER mssql
```

**Examples with Shadoker API**

- [docker/trust/database/sqlserver/Template.dockerfile](../../trust/database/sqlserver/Template.dockerfile)
