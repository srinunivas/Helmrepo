# Images for Fircosoft Multiplexer
These images contain a Multiplexer of a specific version.

## How to build an image for a specific version of the Continuity Multiplexer
To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that provides an easy way for beginners to get started.
Expert users are welcome to directly call `docker build` with their prefered set of parameters.

    $ ./buildDockerImage.sh -h
    
    Usage: buildDockerImage.sh [-t image-name] --fircosoftBaseImage fircosoftBaseImage --multiplexerUri multiplexerUri --multiplexerVersion multiplexerVersion
    Builds a Docker Image for the CoreEngine.
    
    Parameters:
       -t                   : tags the docker image with image-name. Default value is the name of the containing directory.
       --fircosoftBaseImage : fircosoft base image to start from
       --multiplexerUri      : full uri of the multiplexer artifact
       --multiplexerVersion  : multiplexer version

Ex:

    $ ./buildDockerImage.sh \
          -t multiplexer-oraclelinux:5.3.16.14_BTA \
          --fircosoftBaseImage fircosoft-base-oraclelinux \
          --multiplexerUri http://dev-nexus.fircosoft.net/content/sites/site-builds/Continuity/5.3.16.14_BTA.p2-develop-5.3.16.x/ContinuityMultiplexer-5.3.16.14_BTA.p2-linux.tar.gz \
          --multiplexerVersion "5.3.16.14_BTA"

You can also use the simpler [buildDockerImageFromDependencies.sh](buildDockerImageFromDependencies.sh) script. See below for instructions and usage.
This script uses directly the dependency file to build the image and requires no parameters.

    $ ./buildDockerImageFromDependencies.sh 

## How to run the image
To run an image use the docker run command as follows:
Ex:
    $ docker run --name multiplexer-oraclelinux-5.3.16.14_BTA -it multiplexer-oraclelinux:5.3.16.14_BTA
