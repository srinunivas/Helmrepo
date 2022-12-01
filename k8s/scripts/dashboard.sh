#!/bin/bash

# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# Deploy a Helm Release named using the kubernetes-dashboard chart
helm upgrade -i dashboard kubernetes-dashboard/kubernetes-dashboard --set 'service.externalPort=80,protocolHttp=true,ingress.enabled=true,ingress.hosts[0]=dashboard.qabench06sbn.fircosoft.net' --set metricsScraper.enabled=true --set extraArgs="{--enable-insecure-login=true,--disable-settings-authorizer=true}"


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: default             
EOF


cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: default             
EOF


kubectl -n default get secret $(kubectl -n default get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

