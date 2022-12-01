# Fircosoft Continuity Acquisition docker image

This is the official image of Fircosoft Continuity Acquisition

## Run the image

```sh
docker run \ 
--name acquisition \ 
-v "$(pwd)/resources:/opt/fircosoft/continuity/resources" \
jenkins-deploy.fircosoft.net/continuity6/acquisition:6.4.0.0-centos7-coreengine6.2.1.0
```
resources volumes should be mapped, where you can bind **Acquisition.cfg** and **common_env.cfg** and **fbe.cf**

> PS: The only mq mode can be used, please refers to [`shadoker/docker-compose/continuity6/backend`](../../../../docker-compose/continuity6/backend) to see the full configuration


