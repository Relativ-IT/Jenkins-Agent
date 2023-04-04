FROM docker.io/jenkins/inbound-agent:latest

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG PODMAN_REMOTE_ARCHIVE=podman-remote-static-linux_amd64.tar.gz
USER root

RUN apt-get update && apt-get install -y curl && apt-get clean
COPY ${PODMAN_REMOTE_ARCHIVE} ${PODMAN_REMOTE_ARCHIVE}
RUN tar -xvf ${PODMAN_REMOTE_ARCHIVE} --directory / && rm ${PODMAN_REMOTE_ARCHIVE} && \
    mv /bin/$(basename ${PODMAN_REMOTE_ARCHIVE} .tar.gz) /bin/podman

VOLUME ["/home/jenkins/"]
USER jenkins