FROM docker.io/jenkins/inbound-agent:latest

ENV CONTAINER_HOST=unix://run/podman/podman.sock
USER root

#RUN curl -LO https://github.com/containers/podman/releases/latest/download/podman-remote-static.tar.gz && \
RUN curl -LO https://github.com/containers/podman/releases/download/v4.3.1/podman-remote-static.tar.gz && \
    tar -xvf podman-remote-static.tar.gz && rm podman-remote-static.tar.gz && \
    mv podman-remote-static /bin/podman && chmod +x /bin/podman && ln -s /bin/podman /bin/docker

VOLUME ["/home/jenkins/"]
USER jenkins