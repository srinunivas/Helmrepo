#!/bin/bash

# delete previous cluster/registry if any
k3d cluster delete
k3d registry delete myregistry.localhost


# create local registry
k3d registry create myregistry.localhost --port 12345


# create cluster with ingress controller, expose port 8081 to the outside :
k3d cluster create -p "8081:80@loadbalancer" -p "8082:443@loadbalancer" --agents 2 --k3s-server-arg '--no-deploy=traefik' --volume "$(pwd)/helm-ingress-nginx.yaml:/var/lib/rancher/k3s/server/manifests/helm-ingress-nginx.yaml" --registry-use k3d-myregistry.localhost:12345 --volume $HOME/refdata:/refdata --wait


# create a valid mahine-id for fluentbit
docker exec -t k3d-k3s-default-server-0 sh -c "echo `dbus-uuidgen` > /etc/machine-id"
docker exec -t k3d-k3s-default-agent-0  sh -c "echo `dbus-uuidgen` > /etc/machine-id"
docker exec -t k3d-k3s-default-agent-1  sh -c "echo `dbus-uuidgen` > /etc/machine-id"
