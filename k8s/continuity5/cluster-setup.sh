#!/bin/sh

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo add akhq https://akhq.io/
helm repo update
helm install redis --set auth.password=1CAN6dmgBP --set replica.persistence.enabled=false --set master.persistence.enabled=false bitnami/redis
helm install --set deleteTopicEnable=true --set volumePermissions.enabled=true --set zookeeper.volumePermissions.enabled=true kafka bitnami/kafka
helm install -f akhq-values.yaml akhq akhq/akhq
helm upgrade -i jaeger-operator jaegertracing/jaeger-operator
kubectl apply -f jaeger-operator.yaml

wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
dapr init -k
kubectl apply -f dapr.yaml