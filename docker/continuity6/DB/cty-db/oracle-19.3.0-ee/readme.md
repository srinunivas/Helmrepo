# Images for Fircosoft Continuity DB
These images contain an oracle server 19.0.3 enterprise edition and a db user for a specific version of the Continuity DB.
This oracle edition is limited to development usage.

## How to run the image
To run an image use the docker run command as follows:

Ex:

    $ docker run --name cty-db-oracle jenkins-deploy.fircosoft.net/continuity6/cty-db-oracle:master-oracle19cee-dev

The first time the container is started, the continuity and the adv. reporting db users will be created.

## How to connect to the database
To connect to the db system user use the sqlplus commad as follows:

Ex:

    sqlplus sys/Fircosoft00@//localhost:1521/orclcdb as sysdba
    sqlplus system/Fircosoft00@//localhost:1521/orclcdb
    sqlplus pdbadmin/Fircosoft00@//localhost:1521/orclpdb1

To connect to the db continuity user use the sqlplus command as follows:

Ex:

    sqlplus CTY_6_2_2_0/hello00@//localhost:1521/orclpdb1
Or:

    docker exec -ti cty-db-oracle sqlplus CTY_6_2_2_0/hello00@orclpdb1
