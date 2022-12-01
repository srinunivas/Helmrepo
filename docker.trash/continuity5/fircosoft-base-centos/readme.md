# Base image for Fircosoft images
This image can be extended to build other images used by Fircosoft products.
The image is based on centos.
It creates one group : fircosoft
It creates three users in the group : continuity, filter, trust

## How to build the image
To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that provides an easy way for beginners to get started.
Expert users are welcome to directly call `docker build` with their prefered set of parameters.

    $ ./buildDockerImage.sh                
    
    Usage: buildDockerImage.sh [-t image-name] --centosImage centosImage
    Builds a Fircosoft Base Image from a centos image.
    
    Parameters:
       -t: tags the docker image with image-name. Default value is the name of the containing directory.
       --centosImage : centos base image to start from

## How to run the image
No point to run this base image.