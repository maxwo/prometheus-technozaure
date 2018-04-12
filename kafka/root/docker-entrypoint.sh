#!/bin/bash

set -e -o pipefail

# If no broker ID provided, use Rancher metadatas to retrieve sevice index.
if [ -z "${KAFKA_BROKER_ID}" ]; then
    export KAFKA_BROKER_ID=$(hostname | sed 's/.*-//')
fi

if [ -z "${KAFKA_CONTAINER_IP}" ]; then
  export KAFKA_CONTAINER_IP=$(hostname -i | sed 's/.*\///')
fi

if [ -z "${KAFKA_HOST}" ]; then
  export KAFKA_HOST=${KAFKA_CONTAINER_IP}
fi

# If no host name provided, use Rancher metadatas to retrieve host IP
if [ -z "${KAFKA_ADVERTISED_HOST_NAME}" ]; then
    export KAFKA_ADVERTISED_HOST_NAME=${KAFKA_HOST}
fi

printenv

confd -onetime -backend env

# Kafka's built-in start scripts set the first three system properties here, but
# we add two more to make remote JMX easier/possible to access in a Docker
# environment:
#
#   1. RMI port - pinning this makes the JVM use a stable one instead of
#      selecting random high ports each time it starts up.
#   2. RMI hostname - normally set automatically by heuristics that may have
#      hard-to-predict results across environments.
#
# These allow saner configuration for firewalls, EC2 security groups, Docker
# hosts running in a VM with Docker Machine, etc. See:
#
# https://issues.apache.org/jira/browse/CASSANDRA-7087
if [ -z $KAFKA_JMX_OPTS ]; then
    KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true"
    KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
    KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
    KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Dcom.sun.management.jmxremote.rmi.port=${JMX_PORT}"
    KAFKA_JMX_OPTS="${KAFKA_JMX_OPTS} -Djava.rmi.server.hostname=${JAVA_RMI_SERVER_HOSTNAME:-$KAFKA_ADVERTISED_HOST_NAME} "
    export KAFKA_JMX_OPTS
fi

exec $@
