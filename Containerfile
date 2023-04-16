FROM docker.io/jenkins/inbound-agent:latest

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG PODMAN_REMOTE

USER root

COPY ${PODMAN_REMOTE} /bin/podman
RUN chmod +x /bin/podman

VOLUME ["/home/jenkins/"]
USER jenkins