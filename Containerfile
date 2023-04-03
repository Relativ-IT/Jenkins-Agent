FROM docker.io/jenkins/inbound-agent:latest

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG PODMAN_REMOTE=podman-remote-static-linux_amd64.tar.gz
USER root

RUN apt-get update && apt-get install -y curl && apt-get clean
COPY $PODMAN_REMOTE $PODMAN_REMOTE
RUN tar -xvf ${PODMAN_REMOTE} -C / && rm $PODMAN_REMOTE && \
    mv /bin/$(basename ${PODMAN_REMOTE} .tar.gz) /bin/podman

VOLUME ["/home/jenkins/"]
USER jenkins