#!/bin/bash

source ../../setup_env.sh

TARGET_NAMESPACE=${PROMETHEUS_NAMESPACE:-default}

if [[ ${KUBE_CLI} == "kubectl" && ${INSTALL_PROMETHEUS} == "true" ]]; then
  # assuming k8s, install prometheus operator
  LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
  curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | ${KUBE_CLI} delete -f -
fi

# deploy service monitor
${KUBE_CLI} delete -f prometheus/service_monitor.yaml -n ${TARGET_NAMESPACE}

# deploy prometheus rbac
sed -i "s/TARGET_NAMESPACE/${TARGET_NAMESPACE}/g" prometheus/prometheus_rbac.yaml
${KUBE_CLI} delete -f prometheus/prometheus_rbac.yaml -n ${TARGET_NAMESPACE}

# deploy prometheus operator
${KUBE_CLI} delete -f prometheus/prometheus.yaml -n ${TARGET_NAMESPACE}

# expose prometheus
${KUBE_CLI} delete -f prometheus/prometheus_service.yaml -n ${TARGET_NAMESPACE}

echo "prometheus is uninstalled"
