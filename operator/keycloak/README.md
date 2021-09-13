# ArtemisCloud Operator Security Configuration Example - Keycloak Integration

This example demonstrates how to configure security for
an ActiveMQ Artemis broker deployed by [ArtemisCloud operator](https://github.com/artemiscloud/activemq-artemis-operator) to run in a kubernetes/openshift cluster using security custom resources.

The ArtemisCould operator provides a security custom resource definition (CRD) that allows users to configure security for a broker, including

  * JASS login modules for broker and managment console. Currently it supports PropertiesLoginModule, GuestLoginModule and KeycloakLoginModule.
  * Role-based permissions on addresses.
  * Management console role-based access controls.

This example gives a step-by-step procedure to setup a Keycloak server pod and use it as an authentication server for an ActiveMQ Artemis messaging broker and its management console. It also shows how to configure RBAC based access control for addresses and management console.

## Prerequisites

1. Install [Minikube](https://minikube.sigs.k8s.io/docs/) cluster.  You also need kubectl tool.
2. Docker tool for building the image in the example.
3. A [quay.io](https://quay.io) repository for hosting images.

## Step 0 Set up the Keycloak server pod

A keycloak image that is configured with some identities used in this example is prepared and available at
[quay.io](https://quay.io/repository/hgao/keycloak?tab=tags).

Deploy the image to cluser:

    `$ kubectl create -f keycloak.yaml`

To be able to access the Keycloak's admin console, deploy an ingress service:

    `$ kubectl create -f ingress.yaml`

Now you can access the admin console of the keycloak server. Go to

    `https://<keycloak ingress host>`

and login with admin user account (admin/admin)

## Step 1 Deploy ArtemisCloud operator

First deploy all the needed RBAC and CRDs.

    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/service_account.yaml`
    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/role.yaml`
    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/role_binding.yaml`

    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/crds/broker_activemqartemis_crd.yaml`
    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/crds/broker_activemqartemisaddress_crd.yaml`
    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/crds/broker_activemqartemisscaledown_crd.yaml`
    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/crds/broker_activemqartemissecurity_crd.yaml`

Then deploy the Operator. Run:

    `$ kubectl create -f https://raw.githubusercontent.com/artemiscloud/activemq-artemis-operator/master/deploy/operator.yaml`

2. Prepare security configuration CR

    `$ kubectl create -f keycloak-module.yaml`

3. Deploy broker cr:

    `$ kubectl create -f test-broker.yaml`

Check that the broker pod is up and running:
    $ kubectl get pod
    NAME                                        READY   STATUS    RESTARTS   AGE
    activemq-artemis-operator-bb9cf6567-5hrtj   1/1     Running   0          13m
    ex-aao-ss-0                                 1/1     Running   0          4m32s
    keycloak-557f8b4fd4-b4nkp                   1/1     Running   1          22h

4. Create a queue using configured power user

./artemis queue create --user superman --password ihavepower --name Info --address Info --url tcp://ex-aao-ss-0:61616

5. Deploy and run the java client

The client is a java jms client wrapped in an image. It connects to broker as user mdoe which has role amq, that is configured to have consume right on address 'Info'.

To deploy the client:

    `$ `




You need to pas
s in your expected tag as an argument to the script.
For example:

    `$ ./build_custom_init.sh quay.io/hgao/custom-init:broker-mysql-1.0`

The script will build the image, tag it and push it.

The example custom init image will be used in the [broker custom resource file](broker/broker_custom_init.yaml) to configure the broker to use the mysql service as it's persistence store. It copies the jdbc driver jar to broker's lib dir and changes its broker.xml so that it uses database instead of files as data store.

4. Deploy the broker custom resource. Run

    `$ ./deploy_broker_cr.sh <custom init tag>`

It needs the custom init tag built earlier as it's argument. For example

    `$ ./deploy_broker_cr.sh quay.io/hgao/custom-init:broker-mysql-1.0`

The script deploys the broker custom resource **./broker/broker_custom_init.yaml** which uses the custom init image for broker jdbc storage configuration.

Verify that the broker pod is up and running. For example

    $ kubectl get pod
    NAME                                         READY   STATUS    RESTARTS   AGE
    activemq-artemis-operator-7b64475997-r6hls   1/1     Running   0          31m
    ex-aao-ss-0                                  1/1     Running   0          8m1s
    mysql-deployment-c67646cd4-qvxc2             1/1     Running   0          42m

Verify that tables are created in mysql. You can log in to mysql pod's shell and do query, for example:

    $ kubectl exec mysql-deployment-c67646cd4-qvxc2 -ti -- /bin/bash

    # mysql -uroot -ppassword amq_broker
    mysql> show tables;
    +----------------------+
    | Tables_in_amq_broker |
    +----------------------+
    | bindings             |
    | large_messages       |
    | messages             |
    | page_store           |
    +----------------------+
    4 rows in set (0.00 sec)

5. Send some messages

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
    $ ../undeploy_broker_operator.sh
    $ ./undeploy_mysql.sh
