# Install helm

On manjaro :

`sudo snap install helm --classic`

# Install kubectl

On manjaro :

`sudo snap install kubectl --classic`

# Build a test K8S cluster on a dev environment

If you don't already have access to a running K8S cluster you might want to use a K3D cluster that can work on a dev laptop :

https://k3d.io/

The below command creates a new cluster using k3D (it will delete the existing cluster if any) :
Need k3d version 4.4.8

[cluster.sh](../script/cluster.sh)

This script will also create a local registry within which you Continuity images might be pushed - unless your local environement already have access to portus.


# Install Continuity K8S dependencies

Continuity in K8S requires dependencies to be installed (e.g. midlle ware, tracing etc...), the below commands install various dependencies as HELM chart (look into scripts for detail):

[redis.sh](../script/redis.sh)

[kafka.sh](../script/kafka.sh)

[jaeger.sh](../scripts/jaeger.sh)

[akhq.sh](../script/akhq.sh)


# Install K9S - a simple CLI based K8S dashboard

https://github.com/derailed/k9s

On manjaro :

`sudo snap install k9s-nsg`

Troubleshooting : if you got 'Boom!! Unable to locate K8s cluster configuration.', export the KUBECONFIG env. var. again :

`export KUBECONFIG=$HOME/.kube/config`

# Install DAPR


1) Download dapr command line.

`wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash`

2) Install dapr operator within Kubernetes

`dapr init -k`

3) Push Dapr Continuity configurations

`kubectl apply -f dapr.yaml`

4) Deploy persistent volume claim

`kubectl apply -f refdata.persistentvolume.yaml`

5) To remove dapr from kurbernetes

`dapr uninstall -k`

# Push the continuity docker images into the k3d registry

[getContinuityDockerImages.sh](../scripts/getContinuityDockerImages.sh)

# Install Continuity :

The repo contain an exemple values.yaml that can be used for test.

1) provision a new test-local.yaml containing :

The example value.yaml does not contain all keys, you will have to provision them in this test-local.yaml, for example:

    images:
      default:
        backend: "k3d-myregistry.localhost:12345/cty-backend-k8s:local"
        filter: "k3d-myregistry.localhost:12345/filter:local"
        jdbcProxy: "k3d-myregistry.localhost:12345/jdbcproxy:local"
        pullPolicy: Always

    license:
      fbe: |
        # Copy paste the content of your fbe.cf (backend license file)
      fof: |
        # Copy paste the content of your fof.cf (filter license file)
    

2) Install Continuity HELM chart:

`helm install -f values.yaml -f local-test.yaml cty helm/continuity5`

3) Upgrade Continuity HELM chart:

If you have made some changes in your values.yaml you may upgrade you continuity deployment as follow:

`helm upgrade -f values.yaml -f local-test.yaml cty helm/continuity5`

Note: this works as well to reload the filter configuration.

4) Delete Continuity HELM chart:

`helm delete cty`