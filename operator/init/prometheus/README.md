# ArtemisCloud Operator Custom Init Image Example - Prometheus Plugin

This example demonstrates how to use [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) to collect
metrics from brokers deployed by the artemiscloud operator.

Note: The example requires [Artemis Prometheus Metrics Plugin](https://github.com/rh-messaging/artemis-prometheus-metrics-plugin).
As the standard ActiveMQ Artemis distribution isn't shipped with it we use custom init image to install and configure it into the broker.

This example is for demonstration purpose only and is not intended to be used in a real productization environment.

## About ArtemisCloud Broker Operator Custom Init Image

Users can configure ActiveMQ Artemis Broker via custom resources ([examples](https://github.com/artemiscloud/activemq-artemis-operator/tree/master/deploy/examples)). The available configuration parameters are defined in CRD files.

In cases where users need some peculiar aspects of configuration that may be out of scope of CRD definitions,
they can just provide their own custom init image in the custom resource file. During deployment the operator installs the custom init image in broker's init container so it runs before the broker starts. The custom init image's config script will be called so it can adjust the broker configuration as needed.

## Prerequisites

1. You need to have access to a kubernetes cluster. For example you can install a [minikube](https://minikube.sigs.k8s.io/docs/) cluster.  You also need kubectl tool. (You can also choose [CodeReady](https://developers.redhat.com/products/codeready-containers/overview))

2. You need to have docker tool available for building the image in the example.

3. You need to have internet access in order to pull/push images in this example.

4. You need a container registry (e.g. [quay.io](https://quay.io) to push your custom init image to and pull it from.

5. Java JDK version 11.

## Example structure

In the current directory there are a few scripts to help you build and run this example and
there are three sub-directories that contains different kind of resources.

- the **broker** directory has resources for deploying the broker.
- the **custom-init** directory has resources to build the custom init image.
- the **prometheus** directory contains resources needed to deploy a prometheus pod.

## Get started

1. Build the custom init image

    `$ ./build_custom_init.sh` <image tag>

It will download the plugin and build it locally. Then it goes on to build the custom init image
and pushes it to registry.

You need to give a valid image tag as an argument to the script.
For example:

    `$ ./build_custom_init.sh quay.io/hgao/custom-init:1.1.0`

2. Deploy the ArtemisCloud Operator. Run:

    `$ ../../deploy_operator.sh`

Verify that the operator is up and running. For example

    $ kubectl get pod
    NAME                                                   READY   STATUS    RESTARTS   AGE
    activemq-artemis-controller-manager-6b6896f78b-9bscf   1/1     Running   0          4m58s

3. Deploy the broker custom resource. Run

    `$ ./deploy_broker_cr.sh <custom init tag>`

It needs the custom init tag built earlier as it's argument. For example

    `$ ./deploy_broker_cr.sh quay.io/hgao/custom-init:1.1.0`

The script deploys the broker custom resource **./broker/broker_custom_init.yaml**.

Verify that the broker pod is up and running. For example

    $ kubectl get pod
    NAME                                                   READY   STATUS    RESTARTS   AGE
    activemq-artemis-controller-manager-6b6896f78b-9bscf   1/1     Running   0          8m32s
    ex-aao-ss-0                                            1/1     Running   0          14s

4. Deploy Prometheus service.




To verify that messages are actually stored in database. Now use broker's cli tool to send a few messages.

    $ kubectl exec ex-aao-ss-0 -- /bin/bash -c "/home/jboss/amq-broker/bin/artemis producer \
      --user guest --password guest --url tcp://ex-aao-ss-0:61616 --message-count 100"

    amq-broker/bin/artemis producer --user guest --password guest --url tcp://ex-aao-ss-0:61616 --message-count 100
    OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
    Connection brokerURL = tcp://ex-aao-ss-0:61616
    Producer ActiveMQQueue[TEST], thread=0 Started to calculate elapsed time ...

    Producer ActiveMQQueue[TEST], thread=0 Produced: 100 messages
    Producer ActiveMQQueue[TEST], thread=0 Elapsed time in second : 1 s
    Producer ActiveMQQueue[TEST], thread=0 Elapsed time in milli second : 1886 milli seconds

6. Verify the message records in mysql pod

Now login to mysql pod.

    $ kubectl exec mysql-deployment-c67646cd4-qvxc2 -ti -- /bin/bash

    $ mysql -uroot -ppassword amq_broker
    (log in messages omitted)

    mysql> select count(*) from messages;
    +----------+
    | count(*) |
    +----------+
    |      200 |
    +----------+
    1 row in set (0.00 sec)

As you can see there are internal records in the messages table.

7. Cleaning up

To clean up the example run the following scripts in order:

    $ ./undeploy_broker_cr.sh
    $ ../../undeploy_operator.sh
    $ ./undeploy_mysql.sh
