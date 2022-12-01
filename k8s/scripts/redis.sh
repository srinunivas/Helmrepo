#!/bin/bash

helm delete redis
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis --set auth.password=1CAN6dmgBP --set replica.persistence.enabled=false --set master.persistence.enabled=false bitnami/redis

# Get password
export REDIS_PASSWORD=$(kubectl get secret --namespace default redis -o jsonpath="{.data.redis-password}" | base64 --decode)
