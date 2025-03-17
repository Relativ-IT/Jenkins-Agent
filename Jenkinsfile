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
    TAG = "latest"
    FULLIMAGE_PODMAN = "${env.IMAGE_PODMAN}:${env.TAG}"
    FULLIMAGE_BUILDAH = "${env.IMAGE_BUILDAH}:${env.TAG}"
    PODMAN_REMOTE_ARCHIVE = "podman-remote-static-linux_amd64.tar.gz"
    PODMAN_GITHUB_URL = "https://github.com/containers/podman/releases/latest/download" //without trailing '/'
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
      }
    }

    stage("Getting podman remote") {
      options {retry(3)}
      steps {
        sh '''
          curl --parallel --no-progress-meter \
            -LO $PODMAN_GITHUB_URL/$PODMAN_REMOTE_ARCHIVE \
            -LO $PODMAN_GITHUB_URL/shasums
          grep $PODMAN_REMOTE_ARCHIVE shasums | sha256sum --check
        '''
      }
    }

    stage('Building images') {
      steps {
        sh '''
          buildah build \
            --pull=newer \
            --build-arg PODMAN_REMOTE_ARCHIVE=$PODMAN_REMOTE_ARCHIVE \
            --tag $REGISTRY_LOCAL/$FULLIMAGE_PODMAN \
            -f Containerfile-podman
        '''
        sh '''
          buildah build \
            --pull=newer \
            --build-arg SELF_SIGNED_CERT_URL=$SELF_CA_CERT_URL \
            --tag $REGISTRY_LOCAL/$FULLIMAGE_BUILDAH \
            -f Containerfile-buildah
        '''
      }
    }

    stage('Pushing image') {
      steps {
        sh 'buildah push $REGISTRY_LOCAL/$FULLIMAGE_BUILDAH'
        sh 'buildah push $REGISTRY_LOCAL/$FULLIMAGE_PODMAN'
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
