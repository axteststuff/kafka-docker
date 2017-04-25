FROM alpine:latest

ARG kafka_version=0.10.2.0
ARG scala_version=2.12

MAINTAINER wurstmeister

RUN mkdir -p /usr/local/share/ca-certificates
RUN apk add --update curl
RUN curl https://static.gecirtnotification.com/browser_remediation/packages/GE_External_Root_CA_2_1.crt -o /usr/local/share/ca-certificates/GE_External_Root_CA_2_1.pem
RUN apk add --update unzip wget docker jq coreutils openjdk8-jre ca-certificates

ENV KAFKA_VERSION=$kafka_version SCALA_VERSION=$scala_version
ADD download-kafka.sh /tmp/download-kafka.sh
RUN set -x;\
    set -e;\
    chmod a+x /tmp/download-kafka.sh;\
    sync;\
    . /tmp/download-kafka.sh;\
    mkdir /opt;\
    tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt;\
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz;\
    rm -f /opt/kafka;\
    ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD create-topics.sh /usr/bin/create-topics.sh
# The scripts need to have executable permission
RUN chmod a+x /usr/bin/start-kafka.sh && \
    chmod a+x /usr/bin/broker-list.sh && \
    chmod a+x /usr/bin/create-topics.sh
# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
