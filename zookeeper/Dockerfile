FROM openjdk:8u151-jre-stretch

LABEL maintainer="maxime.wojtczak@zenika.com"

# Variables for docker-builder
ARG ZOOKEEPER_VERSION=3.4.10

# Variables for Zookeeper
ENV ZOO_USER=claude66 \
    ZOO_CONF_DIR=/zookeeper/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_PORT=2181 \
    LOGS_DIR=/logs \
    PATH=$PATH:/zookeeper/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR \
    CLASSPATH=/zookeeper/conf \
    JAVA_TOOL_OPTIONS="-javaagent:/etc/prometheus/agent/jmx_prometheus_javaagent-0.10.jar=7071:/zookeeper/conf/zookeeper-jmx-exporter.yml"

# Create user
ARG user=${ZOO_USER}
ARG group=${ZOO_USER}
ARG uid=1666
ARG gid=1666
RUN set -exu \
 && groupadd -g ${gid} ${group} \
 && useradd -d "/home/${user}" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Install JMX agent
RUN set -exu \
 && mkdir -p  /etc/prometheus/agent \
 && curl -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.10/jmx_prometheus_javaagent-0.10.jar \
    --output  /etc/prometheus/agent/jmx_prometheus_javaagent-0.10.jar

# Install confd
RUN set -exu \
 && curl -L https://github.com/kelseyhightower/confd/releases/download/v0.15.0/confd-0.15.0-linux-amd64 \
    --output /usr/local/bin/confd \
 && chmod +x /usr/local/bin/confd

ARG GPG_KEY=C823E3E5B12AF29C67F81976F5CECB3CB5E9BD2D
ARG DISTRO_NAME=zookeeper-${ZOOKEEPER_VERSION}

# Download Apache Zookeeper, verify its PGP signature, untar and clean up
RUN set -exu \
 && apt-get install -y \
        gnupg \
 && wget -q "http://www.apache.org/dist/zookeeper/${DISTRO_NAME}/${DISTRO_NAME}.tar.gz" \
 && wget -q "http://www.apache.org/dist/zookeeper/${DISTRO_NAME}/${DISTRO_NAME}.tar.gz.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key "${GPG_KEY}" \
 && gpg --batch --verify "${DISTRO_NAME}.tar.gz.asc" "${DISTRO_NAME}.tar.gz" \
 && tar -xzf "${DISTRO_NAME}.tar.gz" \
 && ln -s "/${DISTRO_NAME}" /zookeeper \
 && mkdir -p "${ZOO_DATA_LOG_DIR}" "${ZOO_DATA_DIR}" "${ZOO_CONF_DIR}" "${LOGS_DIR}" \
 && chown "${ZOO_USER}:${ZOO_USER}" "${ZOO_DATA_LOG_DIR}" "${ZOO_DATA_DIR}" "${ZOO_CONF_DIR}" "${LOGS_DIR}" \
 && apt-get remove --yes \
        gnupg \
 && apt-get autoremove --yes \
 && rm -r "${GNUPGHOME}" "${DISTRO_NAME}.tar.gz" "${DISTRO_NAME}.tar.gz.asc"

WORKDIR $DISTRO_NAME

COPY root /

VOLUME ["${ZOO_DATA_DIR}", "${ZOO_DATA_LOG_DIR}", "${LOGS_DIR}"]

EXPOSE $ZOO_PORT 2888 3888 7071

USER ${ZOO_USER}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/zookeeper/bin/zkServer.sh", "start-foreground"]
