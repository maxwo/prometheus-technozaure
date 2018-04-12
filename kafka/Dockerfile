FROM openjdk:8u151-jre-stretch

LABEL maintainer="maxime.wojtczak@zenika.com"

# The Scala 2.11 build is currently recommended by the project.
ENV KAFKA_VERSION=1.0.0 \
    SCALA_VERSION=2.11 \
    KAFKA_USER=claude66 \
    LOGS_DIR=/logs \
    DATA_DIR=/data \
    JMX_PORT=7203 \
    KAFKA_PLAINTEXT_PORT=9092 \
    GC_LOG_ENABLED=false \
    KAFKA_OPTS=-javaagent:/etc/prometheus/jmx_prometheus_javaagent-0.10.jar=7071:/etc/prometheus/kafka-jmx-exporter.yml

# Create user
ARG user=${KAFKA_USER}
ARG group=${KAFKA_USER}
ARG uid=1666
ARG gid=1666
RUN set -exu \
 && groupadd -g ${gid} ${group} \
 && useradd -d "/home/${user}" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Install JMX agent
RUN set -exu \
 && mkdir -p  /etc/prometheus/agent \
 && curl -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.10/jmx_prometheus_javaagent-0.10.jar \
    --output  /etc/prometheus/jmx_prometheus_javaagent-0.10.jar

# Install confd
RUN set -exu \
 && curl -L https://github.com/kelseyhightower/confd/releases/download/v0.15.0/confd-0.15.0-linux-amd64 \
    --output /usr/local/bin/confd \
 && chmod +x /usr/local/bin/confd

# Install kafka
RUN set -exu \
 && export KAFKA_DEB_VERSION="${KAFKA_VERSION}-1" \
 && apt-get install --yes \
      gnupg \
 && wget -qO - http://packages.confluent.io/deb/4.0/archive.key | apt-key add - \
 && echo 'deb [arch=amd64] http://packages.confluent.io/deb/4.0 stable main' > /etc/apt/sources.list.d/confluent.list \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
      confluent-kafka-${SCALA_VERSION}=${KAFKA_DEB_VERSION} \
 && apt-get remove --yes \
      gnupg \
 && apt-get autoremove --yes \
 && rm -rf /var/lib/apt/lists/*

COPY root /

# Set up a user to run Kafka
RUN mkdir -p ${DATA_DIR} ${LOGS_DIR} \
 && chown -R ${KAFKA_USER}:${KAFKA_USER} ${DATA_DIR} ${LOGS_DIR} /etc/kafka \
 && rm -rf /var/log/kafka \
 && ln -s ${LOGS_DIR} /var/log/kafka

USER ${KAFKA_USER}

# broker, jmx
EXPOSE ${KAFKA_PORT} ${JMX_PORT} 7071
VOLUME ${DATA_DIR} ${LOGS_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kafka-server-start", "/etc/kafka/server.properties"]
