#!/bin/bash

helm repo add fluent https://fluent.github.io/helm-charts
helm upgrade -i -f fluentbit-values.yaml fluent-bit fluent/fluent-bit 
