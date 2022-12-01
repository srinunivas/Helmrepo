# Fircosoft Continuity Requester docker image

This is the official image of Fircosoft Continuity Requester

## Run the image

```sh
docker run \ 
--name requester \ 
-v "$(pwd)/resources:/opt/fircosoft/continuity/resources" \
-v "$(pwd)/filterData:/opt/fircosoft/continuity/resources/filterData" \
jenkins-deploy.fircosoft.net/continuity6/requester:6.4.0.0-centos7-coreengine6.2.1.0-filter5.8.3.1
```
resources volumes should be mapped, where you can bind **Requester.cfg**, **common_env.cfg** and **fbe.cf**

filterData volumes should be mapped, where you can bind filter resources (FOFDB.KZ,fof.cf, fkof.res, *.t files )

> PS: The only mq mode can be used, please refer to [`shadoker/docker-compose/continuity6/backend`](../../../../docker-compose/continuity6/backend) to see the full configuration