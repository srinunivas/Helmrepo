# Images for Fircosoft Continuity DB
These images contain an oracle server 19.0.3 enterprise edition and a db user for a specific version of the Continuity DB.
This oracle edition is limited to development usage.

## How to build an image for a specific version of the Continuity DB
To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that provides an easy way for beginners to get started.
Expert users are welcome to directly call `docker build` with their prefered set of parameters.

    $ ./buildDockerImage.sh 

    Usage: buildDockerImage.sh [-t image-name] --oracleImage oracleImage --sqlMainUri sqlMainUri --sqlMainVersion sqlMainVersion --sqlBusinessObjectsUri sqlBusinessObjectsUri  --sqlBusinessObjectsVersion sqlBusinessObjectsVersion 
    Builds a Docker Image for Oracle Database.
    
    Parameters:
       -t                 : tags the docker image with image-name. Default value is the name of the containing directory.
       --oracleImage               : oracle image to start from
       --sqlMainUri                : full uri of the main product sql artifact
       --sqlMainVersion            : main product db version
       --sqlMainUri                : full uri of the business objects sql artifact
       --sqlBusinessObjectsVersion : advanced reporting db version

Ex:

    $ ./buildDockerImage.sh \
          -t continuity-db-oracle-19.3.0-ee:5.3.16.4-5.3.16.7 \
          --oracleImage oracle-database-prebuilt:19.3.0-ee \
          --sqlMainUri http://dev-nexus.fircosoft.net/content/sites/site-builds/Continuity/5.3.16.14_BTA.p2-develop-5.3.16.x/Continuity-5.3.16.14_BTA.p2-Sql-Main-Oracle.tar.gz \
          --sqlMainVersion "5.3.16.4" \
          --sqlBusinessObjectsUri http://dev-nexus.fircosoft.net/content/sites/site-builds/Continuity/5.3.16.14_BTA.p2-develop-5.3.16.x/Continuity-5.3.16.14_BTA.p2-Sql-BusinessObjects-Oracle.tar.gz \
          --sqlBusinessObjectsVersion "5.3.16.7" 

You can also use the simpler [buildDockerImageFromDependencies.sh](buildDockerImageFromDependencies.sh) script. See below for instructions and usage.
This script uses directly the dependency file to build the image and requires no parameters.

    $ ./buildDockerImageFromDependencies.sh 

## How to run the image
To run an image use the docker run command as follows:

Ex:

    $ docker run --name continuity-db-oracle-19.3.0-ee-5.3.16.4-5.3.16.7 continuity-db-oracle-19.3.0-ee:5.3.16.4-5.3.16.7

The first time the container is started, the continuity and the adv. reporting db users will be created.

## How to connect to the database
To connect to the db system user use the sqlplus commad as follows:

Ex:

    sqlplus sys/Fircosoft00@//localhost:1521/orclcdb as sysdba
    sqlplus system/Fircosoft00@//localhost:1521/orclcdb
    sqlplus pdbadmin/Fircosoft00@//localhost:1521/orclpdb1

To connect to the db continuity user use the sqlplus command as follows:

Ex:

    sqlplus CTY_5_3_16_4/hello00@//localhost:1521/orclpdb1
Or:

    docker exec -ti continuity-db-oracle-19.3.0-ee-5.3.16.4-5.3.16.7 sqlplus CTY_5_3_16_4/hello00@orclpdb1
