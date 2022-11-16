#!/bin/bash

source ../../setup_env.sh

CUSTOM_INIT_IMAGE_TAG=$1
TARGET_NAMESPACE=${BROKER_NAMESPACE:-default}

if [[ ${CUSTOM_INIT_IMAGE_TAG} == "" ]]; then
    echo "Please pass in the custom image tag"
    exit -1
fi

sed -i "s|initImage.*|initImage: ${CUSTOM_INIT_IMAGE_TAG}|g" ./broker/broker_custom_init.yaml

echo "Deploying broker ..."

cat ./broker/broker_custom_init.yaml

${KUBE_CLI} create -f ./broker/broker_custom_init.yaml -n ${TARGET_NAMESPACE}

echo "Done."
