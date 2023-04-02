FROM docker.io/jenkins/inbound-agent:latest

ENV CONTAINER_HOST=unix://run/podman/podman.sock
USER root

RUN apt-get update && apt-get install -y curl && apt-get clean
ADD $PODMAN_ARCHIVE /
RUN mv /bin/$PODMAN_REMOTE /bin/podman \
    chmod +x /bin/podman

VOLUME ["/home/jenkins/"]
USER jenkins