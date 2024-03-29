# Jenkins-Agent

A containerized jenkins agent based on the official [Docker Inbound Agent](https://github.com/jenkinsci/docker-agent) from [Jenkinsci](https://github.com/jenkinsci) that allow you to use Podman out of Podman.

The first intent of this image is to provide the ability to use Podman from a containerized Jenkins agent, I've choosen the Poop :poop: :innocent: (Podman out of Podman) method that let me drive podman via its host socket.

## Environment

I'm used to work with [Fedora CoreOS](https://getfedora.org/fr/coreos?stream=stable) and I didn't try on another system, that should work in the same way with some adjustments...

## Building the image

Did you really need this section ? well, run `podman build --pull -t jenkins-agent:latest .` in your working directory with the Containerfile.

## Prepare Jenkins

Connect to your.jenkins.instance:port and go to menu 'manage Jenkins/Manage nodes and clouds'

Create a node called `Nodename` (up to you) with "launch method" : `Launch agent by connecting it to the controller` and check the option `Use WebSocket`

Add `/home/jenkins/` as the `Remote root directory` option.
You can add labels like `Linux Podman` in order to select this agent in your pipelines as shown in the following example.

On status page of your newly created agent, you should be able to find the secret key provided by Jenkins for this agent.

## How to use the image

First of all, provide to your system a systemd unit file, in `/etc/systemd/system`, named `podman.socket`, as follow :

``` init
[Unit]
Description=Podman Socket
PartOf=jenkins-agent.service

[Socket]
ListenStream=/tmp/podman-agent.sock
SocketUser=core
SocketMode=600
```

This will create a listening podman socket in `/tmp/podman-agent.sock`

then create the `/etc/systemd/system/jenkins-agent.service` file as follow :

``` init
[Unit]
Description=Podman %n
BindsTo=podman.socket
Wants=network.target
After=network-online.target

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Environment=SECRET=yourabsolutelysecretkeyfromjenkinsitself
Restart=on-failure
ExecStart=/usr/bin/podman run \
  --label="io.containers.autoupdate=image" \
  --hostname=%N \
  --name=%N \
  --replace \
  --detach \
  --network=host \
  -v /tmp/podman-agent.sock:/run/podman/podman.sock \
  -v jenkins-agent-home:/home/jenkins:z \
  -v jenkins-agent-home-agent:/home/jenkins/agent \
  -v jenkins-agent-home-jenkins:/home/jenkins/.jenkins \
  -e JENKINS_WEB_SOCKET=true \
  --security-opt label=disable \
  --init \
  jenkins-agent:latest \
  -workDir=/home/jenkins/agent \
  -url http://your.jenkins.instance:port \
  -secret ${SECRET} \
  -name Nodename
ExecStop=/usr/bin/podman stop %N
Type=forking

[Install]
WantedBy=multi-user.target
```

you can notice the `-v /tmp/podman-agent.sock:/run/podman/podman.sock` that will be driven by the `podman-remote-static` downloaded in Containerfile and moved to `/bin/podman`

For further reading or inspiration or Reverse engineering ^^ how I went here you can look at the `notes.md` file

## For Coreos users, here is the butane file that you can merge in your config

``` yaml
variant: fcos
version: 1.5.0

systemd:
  units:
    - name: podman.socket
      contents: |
        [Unit]
        Description=Podman Socket
        PartOf=jenkins-agent.service

        [Socket]
        ListenStream=/tmp/podman-agent.sock
        SocketUser=core
        SocketMode=600

    - name: jenkins-agent.service
      enabled: true
      dropins:
        - name: env.conf
          contents: |
            [Service]
            Environment=SECRET=yourabsolutelysecretkeyfromjenkinsitself
      contents : |
        [Unit]
        Description=Podman %n
        BindsTo=podman.socket
        Wants=network.target
        After=network-online.target

        [Service]
        Environment=PODMAN_SYSTEMD_UNIT=%n
        Restart=on-failure
        ExecStart=/usr/bin/podman run \
          --label="io.containers.autoupdate=image" \
          --hostname=%N \
          --name=%N \
          --replace \
          --detach \
          --network=host \
          -v /tmp/podman-agent.sock:/run/podman/podman.sock \
          -v jenkins-agent-home:/home/jenkins:z \
          -v jenkins-agent-home-agent:/home/jenkins/agent \
          -v jenkins-agent-home-jenkins:/home/jenkins/.jenkins \
          -e JENKINS_WEB_SOCKET=true \
          --security-opt label=disable \
          --init \
          jenkins-agent:latest \
          -workDir=/home/jenkins/agent \
          -url http://your.jenkins.instance:port ${SECRET} Nodename
        ExecStop=/usr/bin/podman stop %N
        Type=forking

        [Install]
        WantedBy=multi-user.target
```

## Enable and launch service

Everything should be nice now :

`sudo systemctl enable --now jenkins-agent.service`

You should be able to see your agent connected on its status page on Jenkins

## Check if your container is working fine

- Check with `sudo systemctl status jenkins-agent.service podman.socket` if status are `active (running)` and `active (listening)`
- Check with `sudo podman ps` if your container is up and running
- Check with `sudo podman exec jenkins-agent podman version` if you can see infos like e.g. :

``` text
Client:       Podman Engine
Version:      4.5.1
API Version:  4.5.1
Go Version:   go1.20.4
Git Commit:   9eef30051c83f62816a1772a743e5f1271b196d7
Built:        Fri May 26 17:06:52 2023
OS/Arch:      linux/amd64

Server:       Podman Engine
Version:      4.5.0
API Version:  4.5.0
Go Version:   go1.20.2
Built:        Fri Apr 14 15:42:22 2023
OS/Arch:      linux/amd64
```

Create a new test job in jenkins like that and make it run on your new agent :

``` groovy
pipeline{

  agent {
    label 'Linux && Podman'
  }
  
  stages{
    stage('test podman'){
      steps {
        sh '''
          podman version
          podman system info
          podman run --rm docker.io/alpine:latest df -h
        '''
      }
    }
  }
}
```

## Conclusion

This image is building itself as you can suppose by looking at the `Jenkinsfile` :relaxed:
