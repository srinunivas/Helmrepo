#!/bin/bash

helm delete akhq
helm repo add akhq https://akhq.io/
helm install -f akhq-values.yaml akhq akhq/akhq

