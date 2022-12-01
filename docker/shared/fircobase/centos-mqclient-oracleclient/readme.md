# Base image for Fircosoft images
This image can be extended to build other images used by Fircosoft products.
The image is based on centos.
It creates one group : fircosoft
It creates three users in the group : continuity, filter, trust
It adds the fircoof service bind to port 3005/tcp

## How to build the image
o assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

    $ ./shadoker-cli.sh -help

Ex:

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/shared/fircobase:1.0-centos7

## How to run the image
To run an image use the docker run command as follows:
Ex:
    $ docker run --rm -it --name fircobase-1.0-centos7 jenkins-deploy.fircosoft.net/shared/fircobase:1.0-centos7
