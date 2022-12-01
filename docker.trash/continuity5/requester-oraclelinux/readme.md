# Images for Fircosoft Requester
These images contain a Requester of a specific version.

## How to build an image for a specific version of the Continuity Requester
To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that provides an easy way for beginners to get started.
Expert users are welcome to directly call `docker build` with their prefered set of parameters.

    $ ./buildDockerImage.sh -h
    
    Usage: buildDockerImage.sh [-t image-name] --fircosoftBaseImage fircosoftBaseImage --requesterUri requesterUri --requesterVersion requesterVersion
    Builds a Docker Image for the CoreEngine.
    
    Parameters:
       -t                   : tags the docker image with image-name. Default value is the name of the containing directory.
       --fircosoftBaseImage : fircosoft base image to start from
       --requesterUri      : full uri of the requester artifact
       --requesterVersion  : requester version

Ex:

    $ ./buildDockerImage.sh \
          -t requester-oraclelinux:5.3.16.14_BTA \
          --fircosoftBaseImage fircosoft-base-oraclelinux \
          --requesterUri http://dev-nexus.fircosoft.net/content/sites/site-builds/Continuity/5.3.16.14_BTA.p2-develop-5.3.16.x/ContinuityRequester-5.3.16.14_BTA.p2-linux.tar.gz \
          --requesterVersion "5.3.16.14_BTA"

You can also use the simpler [buildDockerImageFromDependencies.sh](buildDockerImageFromDependencies.sh) script. See below for instructions and usage.
This script uses directly the dependency file to build the image and requires no parameters.

    $ ./buildDockerImageFromDependencies.sh 

## How to run the image
To run an image use the docker run command as follows:
Ex:
    $ docker run --name requester-oraclelinux-5.3.16.14_BTA -it requester-oraclelinux:5.3.16.14_BTA
