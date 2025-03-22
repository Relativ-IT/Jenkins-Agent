pipeline {
  triggers {
    cron(env.BRANCH_NAME == 'main' ? '@weekly' : '')
  }

  agent {
    label 'Linux && Buildah'
  }

  environment{
    IMAGE_PODMAN = "jenkins-agent-podman"
    IMAGE_BUILDAH = "jenkins-agent-buildah"
    IMAGE_BUTANE = "jenkins-agent-butane"

    TAG = "latest"

    FULLIMAGE_PODMAN = "${env.IMAGE_PODMAN}:${env.TAG}"
    FULLIMAGE_BUILDAH = "${env.IMAGE_BUILDAH}:${env.TAG}"
    FULLIMAGE_BUTANE = "${env.IMAGE_BUTANE}:${env.TAG}"

    PODMAN_REMOTE_ARCHIVE = "podman-remote-static-linux_amd64.tar.gz"
    PODMAN_GITHUB_URL = "https://github.com/containers/podman/releases/latest/download"

    IGNITION_GITHUB_URL = "https://github.com/coreos/ignition/releases/latest/download"
    IGNITION_FILE = "ignition-validate-x86_64-linux"

    BUTANE_GITHUB_URL = "https://github.com/coreos/butane/releases/latest/download"
    BUTANE_FILE = "butane-x86_64-unknown-linux-gnu"
  }

  stages {
    stage('Initialize') {
      parallel {
        stage('Advertising start of build') {
          steps{
            slackSend color: "#4675b1", message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} started :fire: (<${env.RUN_DISPLAY_URL}|Open>)"
          }
        }

        stage('Print environments variables') {
          steps {
            sh 'printenv | sort'
          }
        }

        stage('Print Buildah infos') {
          steps {
            sh '''
              buildah version
              buildah info
            '''
          }
        }
        
        stage('Get Fedora GPG') {
          steps {
            sh 'curl --no-progress-meter https://fedoraproject.org/fedora.gpg | gpg --import'
          }
        }
      }
    }

    stage("Getting Artefacts") {
      options {retry(3)}
      steps {
        sh '''
          curl --parallel --no-progress-meter \
            -LO $PODMAN_GITHUB_URL/$PODMAN_REMOTE_ARCHIVE \
            -LO $PODMAN_GITHUB_URL/shasums \
            -LO $BUTANE_GITHUB_URL/$BUTANE_FILE \
            -LO $BUTANE_GITHUB_URL/$BUTANE_FILE.asc \
            -LO $IGNITION_GITHUB_URL/$IGNITION_FILE \
            -LO $IGNITION_GITHUB_URL/$IGNITION_FILE.asc
          grep $PODMAN_REMOTE_ARCHIVE shasums | sha256sum --check
          gpg --verify $BUTANE_FILE.asc $BUTANE_FILE
          gpg --verify $IGNITION_FILE.asc $IGNITION_FILE
        '''
      }
    }

    stage('Building images') {
      steps {
        sh '''
          buildah build \
            --pull=newer \
            --build-arg PODMAN_REMOTE_ARCHIVE=$PODMAN_REMOTE_ARCHIVE \
            --build-arg SELF_SIGNED_CERT_URL=$SELF_CA_CERT_URL \
            --tag $REGISTRY_LOCAL/$FULLIMAGE_PODMAN \
            -f Containerfile.Podman
        '''
        sh '''
          buildah build \
            --pull=newer \
            --build-arg SELF_SIGNED_CERT_URL=$SELF_CA_CERT_URL \
            --tag $REGISTRY_LOCAL/$FULLIMAGE_BUILDAH \
            -f Containerfile.Buildah
        '''
        sh '''
          buildah build \
            --pull=newer \
            --build-arg SELF_SIGNED_CERT_URL=$SELF_CA_CERT_URL \
            --build-arg IGNITION_FILE=$IGNITION_FILE \
            --build-arg BUTANE_FILE=$BUTANE_FILE \
            --tag $REGISTRY_LOCAL/$FULLIMAGE_BUTANE \
            -f Containerfile.Butane
        '''
      }
    }

    stage('Pushing image') {
      steps {
        sh 'buildah push $REGISTRY_LOCAL/$FULLIMAGE_BUILDAH'
        sh 'buildah push $REGISTRY_LOCAL/$FULLIMAGE_PODMAN'
        sh 'buildah push $REGISTRY_LOCAL/$FULLIMAGE_BUTANE'
      }
    }
  }

  post {
    success {
      slackSend color: "#4675b1", message: "${env.JOB_NAME} successfully built :blue_heart: !"
    }

    failure {
      slackSend color: "danger", message: "${env.JOB_NAME} build failed :poop: !"
    }
    
    cleanup {
      cleanWs()
    }
  }
}
