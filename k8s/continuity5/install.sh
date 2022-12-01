#!/bin/sh

helm replace --force -f values.yaml -f database.yaml -f images.yaml -f license.yaml cty {{name}}-{{version}}.tgz