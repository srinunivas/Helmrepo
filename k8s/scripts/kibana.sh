#!/bin/bash

helm repo add elastic https://helm.elastic.co

helm upgrade -i kibana elastic/kibana --set 'ingress.enabled=true,ingress.hosts[0]=kibana.qabench06sbn.fircosoft.net,ingress.path=/'


