FROM alpine as java8base

RUN apk update && \
    apk upgrade
RUN apk fetch openjdk8
RUN apk add openjdk8
RUN apk add bash
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH="$JAVA_HOME/bin:${PATH}"

FROM java8base

ADD keycloak /keycloak
ADD cfg /keycloak-cfg

