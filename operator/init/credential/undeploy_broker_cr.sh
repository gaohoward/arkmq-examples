#!/bin/bash

source ../../setup_env.sh

echo "Undeploying broker ..."

${KUBE_CLI} delete -f ./broker/broker_custom_init.yaml

echo "Done."
