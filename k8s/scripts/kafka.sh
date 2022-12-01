#!/bin/bash
helm delete kafka
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install --set deleteTopicEnable=true --set volumePermissions.enabled=true --set zookeeper.volumePermissions.enabled=true kafka bitnami/kafka
