#FROM registry.access.redhat.com/ubi8:8.4-209
#FROM registry.access.redhat.com/ubi8/openjdk-8:1.3-15
FROM alpine as java8base

RUN apk update && \
    apk upgrade
RUN apk fetch openjdk8
RUN apk add openjdk8
RUN apk add bash
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH="$JAVA_HOME/bin:${PATH}"

FROM java8base

ADD keycloak-12.0.3 /keycloak/12.0.3
ADD cfg /keycloak-cfg

RUN ls /keycloak/12.0.3
RUN ls /keycloak-cfg
