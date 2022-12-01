# Images for Fircosoft DBClient
These images contain a coreengine and a dbclient of a specific version.

## How to build an image for a specific version of the DBClient
To assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

    $ ./shadoker-cli.sh -help

Ex:

    $ ./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/continuity5/dbclient:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-oracleclient19.6-coreengine5.6.11.0

## How to run the image
To run an image use the docker run command as follows:
Ex:
To run a bash in the container
    $ docker run  \
        --name dbclient-5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-oracleclient19.6-coreengine5.6.11.0 \
        -it --rm \
        -v ~/work/repos/resources/resources/Continuity/licence/5.3:/home/continuity/resources/continuity5/licence \
        jenkins-deploy.fircosoft.net/continuity5/dbclient:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-oracleclient19.6-coreengine5.6.11.0 \
        /bin/bash

To start the dbclient with default config
    $ docker run \
        --name dbclient-5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-oracleclient19.6-coreengine5.6.11.0 \
        -it --rm \
        -v ~/work/repos/resources/resources/Continuity/licence/5.3:/home/continuity/resources/continuity5/licence \
        jenkins-deploy.fircosoft.net/continuity5/dbclient:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-oracleclient19.6-coreengine5.6.11.0

To start the dbclient with an external config
    $ docker run \
        --name dbclient-5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-oracleclient19.6-coreengine5.6.11.0 \
        -it --rm \
        -v ~/work/repos/resources/resources/Continuity/licence/5.3:/home/continuity/resources/continuity5/licence \
        -v ~/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confA:/home/continuity/resources/continuity5/config \
        jenkins-deploy.fircosoft.net/continuity5/dbclient:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-oracleclient19.6-coreengine5.6.11.0


Note1 : the volume should point to a directory where to find the backend licence.

Ex:
    $ find ~/work/repos/resources/resources
    /home/vagrant/work/repos/resources/resources
    /home/vagrant/work/repos/resources/resources/Continuity
    /home/vagrant/work/repos/resources/resources/Continuity/licence
    /home/vagrant/work/repos/resources/resources/Continuity/licence/5.3
    /home/vagrant/work/repos/resources/resources/Continuity/licence/5.3/fbe.cf


Note2 : the second volume is optional and may point to a directory where to find the config for the module.

Ex:
    $ find ~/work/repos/resources/resources/Continuity/conf/continuity5/dbclient 
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confA
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confA/common_env.cfg
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confA/conf
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confA/conf/DBClient.cfg
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confA/conf/dbclient.out.rule
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confB
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/dbclient/confB/common_env.cfg
