#!/bin/bash

kubectl delete -f keycloak-module-tmp.yaml
kubectl delete -f broker.yaml

rm keycloak-module-tmp.yaml

