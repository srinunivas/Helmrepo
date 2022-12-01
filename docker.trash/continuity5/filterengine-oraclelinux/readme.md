# Images for Fircosoft FilterEngine
These images contain a FilterEngine of a specific version.

## How to build an image for a specific version of the Continuity DB
To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that provides an easy way for beginners to get started.
Expert users are welcome to directly call `docker build` with their prefered set of parameters.

    $ ./buildDockerImage.sh -h
    
    Usage: buildDockerImage.sh [-t image-name] --fircosoftBaseImage fircosoftBaseImage --filterengineUri filterengineUri --filterengineVersion filterengineVersion
    Builds a Docker Image for the CoreEngine.
    
    Parameters:
       -t                   : tags the docker image with image-name. Default value is the name of the containing directory.
       --fircosoftBaseImage : fircosoft base image to start from
       --filterengineUri      : full uri of the filterengine artifact
       --filterengineVersion  : filterengine version

Ex:

    $ ./buildDockerImage.sh \
          -t filterengine-oraclelinux:5.6.5.8 \
          --fircosoftBaseImage fircosoft-base-oraclelinux \
          --filterengineUri http://dev-nexus.fircosoft.net/content/sites/site-builds/filter/5.8.2.0p84/FOF_5.8.2.0_LINUX_64.tar.gz \
          --filterengineVersion "5.6.5.8"

You can also use the simpler [buildDockerImageFromDependencies.sh](buildDockerImageFromDependencies.sh) script. See below for instructions and usage.
This script uses directly the dependency file to build the image and requires no parameters.

    $ ./buildDockerImageFromDependencies.sh 

## How to run the image
In order to start a filter, some info must be provided to the container.
The information to provide are :
- the licence file
- the .kz file or the .t files
- the rules files
- the resources file
- the configuration file
Those files must be provided to the container via a volume in the guest directory /home/filter/resources.
To run an image use the docker run command as follows:
Ex:
    $ docker run --name filterengine-oraclelinux-5.8.2.0 -v /data/vagrant/work/containers/continuity/sol2/resources:/home/filter/resources:ro filterengine-oraclelinux:5.8.2.0
