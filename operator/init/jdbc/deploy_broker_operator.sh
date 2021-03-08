#!/bin/bash

source setup_tool.sh

# deploy RBAC
$KUBE apply -f ${OPR_GITHUB_RAW_BASE}/${OPR_BR}/deploy/service_account.yaml
$KUBE apply -f ${OPR_GITHUB_RAW_BASE}/${OPR_BR}/deploy/role.yaml
$KUBE apply -f ${OPR_GITHUB_RAW_BASE}/${OPR_BR}/deploy/role_binding.yaml

# deploy crds
$KUBE apply -f ${OPR_GITHUB_RAW_BASE}/${OPR_BR}/deploy/crds/broker_activemqartemis_crd.yaml
$KUBE apply -f ${OPR_GITHUB_RAW_BASE}/${OPR_BR}/deploy/crds/broker_activemqartemisaddress_crd.yaml
$KUBE apply -f ${OPR_GITHUB_RAW_BASE}/${OPR_BR}/deploy/crds/broker_activemqartemisscaledown_crd.yaml

# Operator
$KUBE apply -f ${OPR_GITHUB_RAW_BASE}/${OPR_BR}/deploy/operator.yaml

echo "Done."

