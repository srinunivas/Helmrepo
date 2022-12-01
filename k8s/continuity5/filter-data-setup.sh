#!/bin/env sh

kubectl replace --force -f refdata.persistentvolume.yaml
kubectl replace --force -f dataaccess.yaml
mkdir version1
# COPY THESE FILE in version1/ folder
#  - fkof.res
#  - fml.rul
#  - FOFDB.kz
kubectl cp version1 dataaccess:/inbound/