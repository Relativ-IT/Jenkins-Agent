pipeline {
  triggers {
    cron(env.BRANCH_NAME == 'main' ? '@weekly' : '')
  }

  agent {
    label 'Linux && Podman'
  }

  environment{
    IMAGE = "jenkins-agent"
    TAG = "latest"
    FULLIMAGE = "${env.IMAGE}:${env.TAG}"
    PODMAN_REMOTE_ARCHIVE = "podman-remote-static-linux_amd64.tar.gz"
    PODMAN_GITHUB_URL = "https://github.com/containers/podman/releases/latest/download" //without trailing '/'
  }

  stages {
    stage('Initialize') {
      parallel {
        stage('Advertising start of build'){
          steps{
            slackSend color: "#4675b1", message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} started :fire: (<${env.RUN_DISPLAY_URL}|Open>)"
          }
        }

        stage('Print environments variables') {
          steps {
            sh 'printenv'
          }
        }

        stage('Print Podman infos') {
          steps {
            sh '''
              podman version
              podman system info
            '''
          }
        }
      }
    }

    stage("Getting podman remote"){
      parallel {
        stage("Downloading podman remote") {
          steps {
            sh 'curl -LO $PODMAN_GITHUB_URL/$PODMAN_REMOTE_ARCHIVE'
          }
        }
        stage("Downloading Shasums") {
          steps{
            sh 'curl -LO $PODMAN_GITHUB_URL/shasums'
          }
        }
      }
    }

    stage("Check download integrity") {
      steps {
        sh 'grep $PODMAN_REMOTE_ARCHIVE shasums | sha256sum --check'
      }
    }

    stage('Building image') {
      steps {
        sh 'podman build --pull --build-arg PODMAN_REMOTE_ARCHIVE=$PODMAN_REMOTE_ARCHIVE -t $LOCAL_REGISTRY/$FULLIMAGE .'
      }
    }

    stage('Pushing image') {
      steps {
        sh 'podman push $LOCAL_REGISTRY/$FULLIMAGE'
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
      sh '''
        podman container prune --force
        podman image prune --force
      '''
      cleanWs()
    }
  }
}
