FROM docker.io/jenkins/inbound-agent

USER root

RUN apt-get update && apt-get install -y curl
RUN curl -LO https://github.com/containers/podman/releases/latest/download/podman-remote-static.tar.gz
RUN tar -xvf podman-remote-static.tar.gz && rm podman-remote-static.tar.gz
RUN mv podman-remote-static /bin/podman && chmod +x /bin/podman
RUN apt-get clean
ENV CONTAINER_HOST=unix://run/podman/podman.sock

VOLUME ["/home/jenkins/"]
USER jenkins