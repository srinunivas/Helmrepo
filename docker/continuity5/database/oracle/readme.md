# Images for Fircosoft Continuity DB
These images contain an oracle server 19.0.3 enterprise edition and a db user for a specific version of the Continuity DB.
This oracle edition is limited to development usage.

## How to auto-generate the imageData files and the artifacts files
To generate the imageData files and the references/artifacts files automaticcally, you can use the tool manifesto

    $ docker run -it --rm -e CONTINUITY_DB_VERSION='5.3.19.0' -v $(pwd):/shadoker -w /shadoker jenkins-deploy.fircosoft.net/shadoker/manifesto docker/continuity5/database/oracle/database.mjs

## How to build an image for a specific version of the Continuity DB
To assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

    $ ./shadoker-cli.sh -help

Ex:

    $ ./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/continuity5/database:5.3.19.0-oracle19cee 

## How to run the image
To run an image use the docker run command as follows:

Ex:

    $ docker run --name continuity5-database-5.3.19.0-oracle19cee jenkins-deploy.fircosoft.net/continuity5/database:5.3.19.0-oracle19cee

## How to connect to the database

The system user is:
    User : SYSTEM
    UserPwd : Fircosoft00

The continuity user is:
    User : continuity5
    UserPwd : Hello00

The version of the schema is indicated in the name of the image.
Ex:
    Image name : jenkins-deploy.fircosoft.net/continuity5/database:5.3.19.0-oracle19cee
    Schema version : 5.3.19.0

To connect to the db system user use the sqlplus commad as follows:

Ex:

    sqlplus sys/Fircosoft00@//localhost:1521/orclcdb as sysdba
    sqlplus system/Fircosoft00@//localhost:1521/orclcdb
    sqlplus pdbadmin/Fircosoft00@//localhost:1521/orclpdb1

To connect to the db continuity user use the sqlplus command as follows:

Ex:

    sqlplus continuity5/hello00@//localhost:1521/orclpdb1
Or:

    docker exec -ti continuity5-database-5.3.19.0-oracle19cee sqlplus continuity5/hello00@orclpdb1
