FROM docker.io/jenkins/inbound-agent:latest

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG PODMAN_REMOTE

USER root
RUN apt-get update && apt-get install -y curl && apt-get clean

COPY ${PODMAN_REMOTE} /bin/podman

VOLUME ["/home/jenkins/"]
USER jenkins