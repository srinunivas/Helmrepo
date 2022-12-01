#!/bin/bash
helm delete jaeger-operator
# Install Jaeger
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade -i jaeger-operator jaegertracing/jaeger-operator
kubectl apply -f jaeger-operator.yaml

