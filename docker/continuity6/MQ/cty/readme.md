### Author 
Maamoun Soltani
#### About
The docker_run_mq9serv.sh creates an MQ container that includes the most used queues from the Continuity Application.
The Template image is from https://hub.docker.com/_/ibm-mq-advanced
The Image source code is from https://github.com/ibm-messaging/mq-container/blob/9.1.2/Dockerfile-server
The MQ Server version is 9.1.2.0
#### Prerequisite
Linux Host, docker installed, internet connection.
#### How to
Run :
sudo docker_run_mq9serv.sh
wait until image is pulled and started, then go to https://localhost:9443/ibmmq/console/login.html 
(admin/passw0rd)
The Continuity mq connection string is then :
mqseries-manager QM '"QM1"' force-mqclient host 'localhost(1414)' channel 'QM1_CHL'
#### To go further
The Container is based on the store/ibmcorp/mqadvanced-server-dev:9.1.2.0 image
which is built with a preconfigured queue manager, channel and queue.
The 20-config.mqsc will be copied into the /etc/mqm/ folder 
The 20-config.mqsc contains MQ Channel and an Queues definitions for continuity 
It will be executed when the Image is built.