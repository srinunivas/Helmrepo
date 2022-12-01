# Fircosoft "Orchestrator"  docker image

This is image of Continuity Orchestrator application with a mock/dummy engine "dummy-requester"

## How to run the image
To run an image use the docker run command as follows:

Ex:

    $ docker run  --rm --name OREN \
                - 2121:2121             #vsftp listener port : used only for integration test
                - 7000-8000:7000-8000   #vsftp port ranges
                - 1022:22               #ssh port
                - 1044:1044             #java debug port : used only for dev
                - 36320:36320           #jacoco agent port
                - 8080:80               #http port : used for health check
                - 9001:9001             #supervisord port : used for graceful shutdown : : used only for integration test
                        -v "`pwd`/data/oren/conf":"/usr/local/orchestrator-app/conf" \
                        jenkins-deploy.fircosoft.net/continuity6/orchestrator:master-UBUNTU18-OPENJDK8


In order to properly configure the orchestrator, Required volumes should be bounded before :

- `data/oren/conf` : contains orchestrator configuration file and SSL config files : jks keys serverKeystore.jks for TLS  & serverTruststore for mTLS 

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
        │   ├── conf
        │   ├── Orchestrator
        │       ├── orchestrator-6.XYZ.jar




