# Notes

podman unshare chown 1000:1000 /run/user/1000/podman/podman.sock
podman run -d --name jenkins-agent -v /run/user/1000/podman/podman.sock:/run/podman/podman.sock --security-opt label=disable --replace --init test -url <http://jenkins:8080> secertkey Nodename
<https://github.com/containers/podman/blob/main/docs/tutorials/remote_client.md>
<https://github.com/containers/podman/issues/6015#issuecomment-628585870>
<https://www.tutorialworks.com/podman-rootless-volumes/>
<https://redhat-scholars.github.io/build-a-container/intro-container-workshop/1.0/PODMAN_ROOTLESS/podman-rootless.html>

UNIT ? : rootless, look at the --userns=keep-id !!
podman system service --timeout 0 unix:///tmp/podman.sock
sudo chmod 666 /tmp/podman.sock
podman run -d --userns=keep-id --name jenkins-agent -v /tmp/podman.sock:/run/podman/podman.sock --security-opt label=disable --replace --init test -url <http://jenkins:8080> secertkey Nodename
