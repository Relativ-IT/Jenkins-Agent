FROM docker.io/jenkins/inbound-agent:latest-jdk17

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG PODMAN_REMOTE_ARCHIVE

USER root

COPY ${PODMAN_REMOTE_ARCHIVE} ${PODMAN_REMOTE_ARCHIVE}

RUN tar -xf ${PODMAN_REMOTE_ARCHIVE} --directory / && \
    rm ${PODMAN_REMOTE_ARCHIVE} && \
    mv /bin/$(basename ${PODMAN_REMOTE_ARCHIVE} .tar.gz) /bin/podman

VOLUME ["/home/jenkins/"]
USER jenkins