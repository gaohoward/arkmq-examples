#!/bin/bash

echo "############## Example Custom Script ###############"
echo "##                                                ##"
echo "##      This is an example configure script.      ##"
echo "##                                                ##"
echo "####################################################"

echo "#### The config dir locates at ${CONFIG_INSTANCE_DIR} ####"
ls ${CONFIG_INSTANCE_DIR}

echo "#### Copying prometheus plugin jars ####"
cp /amq/prometheus-plugin/artemis-prometheus-metrics-plugin-1.1.0.CR1/artemis-prometheus-metrics-plugin/target/artemis-prometheus-metrics-plugin-1.1.0.jar ${CONFIG_INSTANCE_DIR}/lib
ls ${CONFIG_INSTANCE_DIR}/lib
mkdir ${CONFIG_INSTANCE_DIR}/web
cp /amq/prometheus-plugin/artemis-prometheus-metrics-plugin-1.1.0.CR1/artemis-prometheus-metrics-plugin-servlet/target/metrics.war ${CONFIG_INSTANCE_DIR}/web
ls ${CONFIG_INSTANCE_DIR}/web

sed -i 's/<\/binding>/           <app url="metrics" war="metrics.war"\/>\n       <\/binding>/g' ${CONFIG_INSTANCE_DIR}/etc/bootstrap.xml

cat ${CONFIG_INSTANCE_DIR}/etc/bootstrap.xml

echo "#### Custom config done. ####"
