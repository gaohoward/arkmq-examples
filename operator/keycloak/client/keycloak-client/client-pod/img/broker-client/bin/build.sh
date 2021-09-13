#!/bin/bash

echo compiling...
javac -classpath ../lib/artemis-jms-client-all-2.18.0-SNAPSHOT.jar ../src/org/apache/artemis/keycloakclient/KeycloakSecurityExample.java

echo running...
java -classpath ../lib/artemis-jms-client-all-2.18.0-SNAPSHOT.jar:../src org.apache.artemis/keycloakclient/KeycloakSecurityExample
