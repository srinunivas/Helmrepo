#!/bin/bash

# deploy kubeview helm chart
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm upgrade -i kubeview cowboysysop/kubeview --set 'ingress.enabled=true,ingress.hosts[0].paths[0]=/,ingress.hosts[0].host=kubeview.qabench06sbn.fircosoft.net'
