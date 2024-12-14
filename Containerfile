FROM docker.io/jenkins/inbound-agent:jdk21

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG PODMAN_REMOTE_ARCHIVE

USER root

RUN apt-get update && apt-get install --no-install-recommends -y jq gpg && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ${PODMAN_REMOTE_ARCHIVE} ${PODMAN_REMOTE_ARCHIVE}

RUN tar -xf ${PODMAN_REMOTE_ARCHIVE} --directory / && \
    mv /$(tar -tf ${PODMAN_REMOTE_ARCHIVE}) /bin/podman && \
    rm ${PODMAN_REMOTE_ARCHIVE}

VOLUME ["/home/jenkins/"]
USER jenkins