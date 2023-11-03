FROM docker.io/jenkins/inbound-agent:latest-jdk17

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG PODMAN_REMOTE_ARCHIVE

USER root

RUN apt-get update && apt-get install jq gpg -y && apt-get clean

COPY ${PODMAN_REMOTE_ARCHIVE} ${PODMAN_REMOTE_ARCHIVE}

RUN tar -xf ${PODMAN_REMOTE_ARCHIVE} --directory / && \
    mv /$(tar -tf ${PODMAN_REMOTE_ARCHIVE}) /bin/podman && \
    rm ${PODMAN_REMOTE_ARCHIVE}

VOLUME ["/home/jenkins/"]
USER jenkins