# Fircosoft Continuity Stripping docker image

This is the official image of Fircosoft Continuity Stripping

## Run the image

```sh
docker run \ 
--name stripping \ 
-v "$(pwd)/resources:/opt/fircosoft/continuity/resources" \
jenkins-deploy.fircosoft.net/continuity6/stripping:6.4.0.0-centos7-coreengine6.2.1.0
```
 
resources volumes should be mapped, where you can bind **Stripping.cfg**, **common_env.cfg** and **fbe.cf**

> PS: The only mq mode can be used, please refer to [`shadoker/docker-compose/continuity6/backend`](../../../../docker-compose/continuity6/backend) to see the full configuration.

### Run InternalFeeder

```sh
docker run \ 
--name stripping \ 
-v "$(pwd)/resources:/opt/fircosoft/continuity/resources" \
jenkins-deploy.fircosoft.net/continuity6/stripping:6.4.0.0-centos7-coreengine6.2.1.0 InternalFeeder
```

### Run RuleRecorder 

In case of inserting rules, you run Stripping as follow:

```sh
docker run \ 
--rm 
--name stripping \ 
-v "$(pwd)/resources:/opt/fircosoft/continuity/resources" \
-v "$(pwd)/rules:/opt/fircosoft/continuity/resources/rules" \
jenkins-deploy.fircosoft.net/continuity6/stripping:6.4.0.0-centos7-coreengine6.2.1.0 RuleRecorder
```

rules volumes should be mapped