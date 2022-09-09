pipeline {
  
  triggers {
    cron(env.BRANCH_NAME == 'main' ? '@weekly' : '')
  }

  agent {
    label 'Linux' && 'Podman'
  }

  environment{
    REGISTRY = credentials('registry-server')
    IMAGE = "jenkins-agent"
    TAG = "latest"
    FULLIMAGE = "${env.IMAGE}:${env.TAG}"
  }

  stages {

    stage('Advertising start of build'){
      steps{
        slackSend color: "#4675b1", message: "${env.JOB_NAME} build #${env.BUILD_NUMBER} started :fire: (<${env.RUN_DISPLAY_URL}|Open>)"
      }
    }

    stage('Building image') {
      steps {
        sh 'podman build --pull -t $REGISTRY/$FULLIMAGE .'
      }
    }

    stage('Pushing image') {
      steps {
        sh 'podman push $REGISTRY/$FULLIMAGE'
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
