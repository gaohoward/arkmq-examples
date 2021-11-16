#!/bin/bash

echo "############## Example Custom Script ###############"
echo "##                                                ##"
echo "##      This is an example configure script.      ##"
echo "##                                                ##"
echo "####################################################"

echo "#### The config dir locates at ${CONFIG_INSTANCE_DIR} ####"
ls ${CONFIG_INSTANCE_DIR}

echo "#### Copying keycloak jars to ${CONFIG_INSTANCE_DIR}/lib ####"
cp /amq/keycloak-jars/*.jar ${CONFIG_INSTANCE_DIR}/lib

echo "#### Custom config done. ####"
