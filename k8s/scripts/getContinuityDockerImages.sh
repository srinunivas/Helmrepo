#!/bin/bash

DOCKER_REGISTRY_SOURCE=jenkins-deploy.fircosoft.net
DOCKER_REGISTRY_TARGET=k3d-myregistry.localhost:12345

DOCKER_IMAGES_LIST=()
DOCKER_IMAGES_LIST+=(continuity5/backend-k8s:5.3.25.1_k8s-centos7-coreengine5.6.13.1_k8s-develop)
DOCKER_IMAGES_LIST+=(continuity5/jdbcproxy:5.6.13.1_k8s-alpinejre-11.0.11_9-openjdk11-develop)
DOCKER_IMAGES_LIST+=(continuity5/verify-web:5.3.25.1-tomcat9.0.37-openjdk11-continuity5.3.25.1)
DOCKER_IMAGES_LIST+=(continuity5/deployment-console:5.3.25.1-centos7-sqlserverclient17.8.1.1-1-openjdk11-continuity5.3.25.1)
DOCKER_IMAGES_LIST+=(continuity5/deployment-console:5.3.25.1-centos7-oracleclient19.12.0.0.0-openjdk11-continuity5.3.25.1)
DOCKER_IMAGES_LIST+=(filter/filter-engine-k8s:5.7.3.4)

for image in "${DOCKER_IMAGES_LIST[@]}"; do
    docker pull ${DOCKER_REGISTRY_SOURCE}/${image}
    docker tag ${DOCKER_REGISTRY_SOURCE}/${image} ${DOCKER_REGISTRY_TARGET}/${image}
    docker push ${DOCKER_REGISTRY_TARGET}/${image}
done
