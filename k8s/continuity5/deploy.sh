#!/bin/sh

helm delete cty
helm install -f values.yaml -f local-test.yaml cty helm/continuity5
