# Fircosoft "Orchestrator"  docker image

This is image of Continuity Orchestrator application which embed Universal mapper 

## How to run the image
To run an image use the docker run command as follows:

Ex:

    $ docker run  --rm --name OREN \
                -p 8080:80               #http port : used for health check
                -v "`pwd`/data/oren/conf":"/usr/local/orchestrator-app/conf" \
                jenkins-deploy.fircosoft.net/continuity/orchestrator:latest-ubuntu18.04-openjdk11
                ./Start_Orchestrator.sh

**NB :** In order to properly configure the orchestrator, a custom configuration should be mounted as a docker volume. For example :

- `data/oren/conf/ssl` : contains orchestrator configuration file and SSL config files : jks keys serverKeystore.jks for TLS  & serverTruststore for mTLS 

#### Example of `data` volume folder

     data    
        ├── oren
        │   ├── conf
        │   │   ├── orchestrator.properties
        │       └──── ssl
        │           ├── serverKeystore.jks
        │           └── serverTruststore.jks


#### Docker container File system

The root directory for the orchestrator application is */usr/local/orchestrator-app* and its structure is as follow :

     /usr/local    
        ├── orchestrator-app
        │   ├── work
        │   ├── log
        │   ├── fcl
        │   ├── conf
        │   ├── Orchestrator
        │       ├── orchestrator-XYZ.jar




