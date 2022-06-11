#!/bin/bash
source ../../setup_env.sh

KEYCLOAK_VER=18.0.0

function printUsage() {
  main_name=`basename "$0"`
  echo "Usage:"
  echo "${main_name} <quay.io user name> <quay.io repo name>"
}

params_ready=true
if [ -z "$1" ]
  then
    echo "Missing quay.io user name"
    params_ready=false
fi
if [ -z "$2" ]
  then
    echo "Missing quay.io repo name"
    params_ready=false
fi
if [ ${params_ready} = "false" ]
  then
    printUsage
    exit 1
fi

wget https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VER}/keycloak-${KEYCLOAK_VER}.tar.gz

tar xvf keycloak-${KEYCLOAK_VER}.tar.gz

mv -v keycloak-${KEYCLOAK_VER} keycloak

docker build -t quay.io/$1/$2:keycloak-${KEYCLOAK_VER} .

docker push quay.io/$1/$2:keycloak-${KEYCLOAK_VER}

sed  "s|REPO_USER|$1|" keycloak.yaml > keycloak_tmp.yaml
sed -i "s|REPO_NAME|$2|" keycloak_tmp.yaml
sed -i "s|KEYCLOAK_TAG|keycloak-${KEYCLOAK_VER}|" keycloak_tmp.yaml

${KUBE_CLI} create -f keycloak_tmp.yaml
