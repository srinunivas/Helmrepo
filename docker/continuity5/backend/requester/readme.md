# Images for Fircosoft CoreEngine
These images contain a coreengine and a requester of a specific version.

## How to build an image for a specific version of the Requester
To assist in building the images, you can use the [shadoker-cli.sh](shadoker-cli.sh) script. See below for instructions and usage.

    $ ./shadoker-cli.sh ./shadoker-cli.sh docker build -d <my_image_name:my_tag>

See confluence page for more information : http://confluence.fircosoft.net/pages/viewpage.action?spaceKey=DTP&title=Shadoker+usage+for+development+teams

Or 

    $ ./shadoker-cli.sh -help

Ex:

    $ ./shadoker-cli.sh docker build -d jenkins-deploy.fircosoft.net/continuity5/requester:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-coreengine5.6.11.0-filter5.8.9.0

## How to run the image
To run an image use the docker run command as follows:
Ex:
To run a bash in the container
    $ docker run \
        --name requester-5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-coreengine5.6.11.0-filter5.8.9.0 \
        -it --rm \
        -v ~/work/repos/resources/resources/Continuity/licence/5.3:/home/continuity/resources/continuity5/licence \
        -v ~/work/repos/resources/resources/filter/licence/5.8:/home/continuity/resources/filter/licence \
        -v ~/work/repos/resources/resources/filter/conf/default:/home/continuity/resources/filter/config \
        jenkins-deploy.fircosoft.net/continuity5/requester:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-coreengine5.6.11.0-filter5.8.9.0 \
        /bin/bash

To start the requester with default config
    $ docker run \
        --name requester-5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-coreengine5.6.11.0-filter5.8.9.0 \
        -it --rm \
        -v ~/work/repos/resources/resources/Continuity/licence/5.3:/home/continuity/resources/continuity5/licence \
        -v ~/work/repos/resources/resources/filter/licence/5.8:/home/continuity/resources/filter/licence \
        -v ~/work/repos/resources/resources/filter/conf/default:/home/continuity/resources/filter/config \
        jenkins-deploy.fircosoft.net/continuity5/requester:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-coreengine5.6.11.0-filter5.8.9.0

To start the requester with an external config
    $ docker run \
        --name requester-5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-coreengine5.6.11.0-filter5.8.9.0 \
        -it --rm \
        -v ~/work/repos/resources/resources/Continuity/licence/5.3:/home/continuity/resources/continuity5/licence \
        -v ~/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA:/home/continuity/resources/continuity5/config \
        -v ~/work/repos/resources/resources/filter/licence/5.8:/home/continuity/resources/filter/licence \
        -v ~/work/repos/resources/resources/filter/conf/default:/home/continuity/resources/filter/config \
        jenkins-deploy.fircosoft.net/continuity5/requester:5.3.23.0-centos7-fircobase1.0-webspheremq9.1.3-coreengine5.6.11.0-filter5.8.9.0

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
    $ find ~/work/repos/resources/resources/Continuity/conf/continuity5/requester 
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA/common_env.cfg
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA/conf
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA/conf/requester.out.ws.rule
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA/conf/Requester.cfg
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA/conf/requester.out.rule
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confA/conf/requester.out.stp.rule
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confB
    /home/vagrant/work/repos/resources/resources/Continuity/conf/continuity5/requester/confB/common_env.cfg


Note3 : the third volume should point to a directory where to find the filter config.

Ex:
    $ find ~/work/repos/resources/resources/filter 
    /home/vagrant/work/repos/resources/resources/filter
    /home/vagrant/work/repos/resources/resources/filter/conf
    /home/vagrant/work/repos/resources/resources/filter/conf/default
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fofcisy.t
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fofstsy.t
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fof.cfg
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fmlxx.rul
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fofcosy.t
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fml.rul
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fofnasy.t
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fkof.res
    /home/vagrant/work/repos/resources/resources/filter/conf/default/fofdbof.t
    /home/vagrant/work/repos/resources/resources/filter/licence
    /home/vagrant/work/repos/resources/resources/filter/licence/5.7
    /home/vagrant/work/repos/resources/resources/filter/licence/5.7/fof.cf
    /home/vagrant/work/repos/resources/resources/filter/licence/5.8
    /home/vagrant/work/repos/resources/resources/filter/licence/5.8/fof.cf
