#!/bin/bash

source ../../setup_env.sh

CUSTOM_INIT_IMAGE_TAG=$1
PROMETHEUS_PLUGIN_TAG=2.0.0
PROMETHEUS_PLUGIN_VERSION=v${PROMETHEUS_PLUGIN_TAG}

if [[ ${CUSTOM_INIT_IMAGE_TAG} == "" ]]; then
    echo "Please pass in image tag, e.g. quay.io/hgao/custom-init:broker-prometheus-1.1.0"
    exit -1
fi
if [[ ! -f "custom-init/prometheus-plugin/artemis-prometheus-metrics-plugin-${PROMETHEUS_PLUGIN_VERSION}.zip" ]]; then
    echo "Downloading prometheus plugin ..."
    mkdir -p custom-init/prometheus-plugin
    curl -L https://github.com/rh-messaging/artemis-prometheus-metrics-plugin/archive/refs/tags/${PROMETHEUS_PLUGIN_VERSION}.zip \
     --output custom-init/prometheus-plugin/artemis-prometheus-metrics-plugin-${PROMETHEUS_PLUGIN_VERSION}.zip
fi
unzip custom-init/prometheus-plugin/artemis-prometheus-metrics-plugin-${PROMETHEUS_PLUGIN_VERSION}.zip -d custom-init/prometheus-plugin

pushd custom-init/prometheus-plugin/artemis-prometheus-metrics-plugin-${PROMETHEUS_PLUGIN_TAG}/
mvn install
popd

echo "Building custom init image using tag: ${CUSTOM_INIT_IMAGE_TAG}"

docker build -t ${CUSTOM_INIT_IMAGE_TAG} ./custom-init

docker push ${CUSTOM_INIT_IMAGE_TAG}
