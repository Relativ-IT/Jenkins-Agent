FROM docker.io/jenkins/inbound-agent:latest

ENV CONTAINER_HOST=unix://run/podman/podman.sock
ARG Binary=podman-remote-static-linux_amd64
USER root

RUN apt-get update && apt-get install -y curl && apt-get clean
RUN curl -LO https://github.com/containers/podman/releases/latest/download/${Binary}.tar.gz && \
    tar -xvf ${Binary}.tar.gz -C / && rm ${Binary}.tar.gz && \
    mv /bin/${Binary} /bin/podman && chmod +x /bin/podman && ln -s /bin/podman /bin/docker

VOLUME ["/home/jenkins/"]
USER jenkins