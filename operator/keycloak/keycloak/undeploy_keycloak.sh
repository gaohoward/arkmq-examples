#!/bin/bash

source ../../setup_env.sh

rm keycloak-*.tar.gz

rm -rf keycloak

${KUBE_CLI} delete -f keycloak_tmp.yaml

rm keycloak_tmp.yaml

