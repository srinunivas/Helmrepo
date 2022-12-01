# Images for Fircosoft Continuity DB
These images contain a microsoft sql server 2019 and a db user for a specific version of the Continuity DB.
This microsoft sql server edition is limited to development usage.

## How to run the image
To run an image use the docker run command as follows:

Ex:

   docker run --name cty-db-mssql -p 1433:1433  -d jenkins-deploy.fircosoft.net/continuity6/cty-db-sqlserver:master-mssql2019-dev 

The first time the container is started, the continuity db user will be created.

## How to connect to the database
There are two user accounts for db connection:

admin user:
 username: sa
 passowrd: Hello0011

User : 
 username: CTY_DOCKER
 password: hello00

database name: continuityDB

To connect to the db continuity use the sqlcmd command as follows:

    docker exec -ti cty-db-mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'Hello0011' -d "continuityDB" -Q "<DB query>"