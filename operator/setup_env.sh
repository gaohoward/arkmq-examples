#!/bin/bash
LATEST_TAG=$(git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort='version:refname' --tags https://github.com/artemiscloud/activemq-artemis-operator.git '*.*.*' | tail --lines=1 | cut --delimiter='/' --fields=3)

export OPERATOR_VERSION=${OPERATOR_VERSION:-${LATEST_TAG}}

echo "Using operator version ${OPERATOR_VERSION}"

if command -v kubectl &> /dev/null
then
    echo "using kubectl"
    export KUBE_CLI=kubectl
elif command -v oc &> /dev/null
then
    echo "using oc"
    export KUBE_CLI=oc
else
    echo "You need install kubectl (for minikube) or oc (for codeready)"
fi
