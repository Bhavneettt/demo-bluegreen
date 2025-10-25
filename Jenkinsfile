pipeline {
  agent any
  environment {
    REGISTRY = credentials('dockerhub')     // Jenkins cred ID
    IMAGE_NAME = "demo"
    K8S_NAMESPACE = "demo"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build Image') {
      steps {
        script {
          def current = sh(script: """
            kubectl -n ${K8S_NAMESPACE} get svc demo -o jsonpath='{.spec.selector.version}' || echo blue
          """, returnStdout: true).trim()
          def newColor = (current == 'green') ? 'blue' : 'green'
          env.NEW_COLOR = newColor
          env.IMAGE_TAG = "${newColor}-${env.BUILD_NUMBER}"
          sh """
            docker login -u "$REGISTRY_USR" -p "$REGISTRY_PSW"
            docker build -t bhavneettt/${IMAGE_NAME}:${IMAGE_TAG} .
            docker push bhavneettt/${IMAGE_NAME}:${IMAGE_TAG}
          """
        }
      }
    }
    stage('Deploy idle color') {
      steps {
        script {
          def dep = "demo-${env.NEW_COLOR}"
          sh "kubectl -n ${K8S_NAMESPACE} apply -f k8s/deploy-${env.NEW_COLOR}.yaml"
          sh "kubectl -n ${K8S_NAMESPACE} set image deployment/${dep} app=bhavneettt/${IMAGE_NAME}:${IMAGE_TAG}"
          sh "kubectl -n ${K8S_NAMESPACE} rollout status deployment/${dep} --timeout=90s"
        }
      }
    }
    stage('Smoke Test') {
      steps {
        sh """
          POD=$(kubectl -n ${K8S_NAMESPACE} get pod -l app=demo,version=${NEW_COLOR} -o jsonpath='{.items[0].metadata.name}')
          kubectl -n ${K8S_NAMESPACE} exec $POD -- wget -qO- http://localhost:3000/health
        """
      }
    }
    stage('Flip Service') {
      steps {
        sh """
          kubectl -n ${K8S_NAMESPACE} patch svc demo \
            -p '{\"spec\":{\"selector\":{\"app\":\"demo\",\"version\":\"${NEW_COLOR}\"}}}'
        """
      }
    }
    stage('Scale down old color') {
      steps {
        script {
          def oldColor = (env.NEW_COLOR == 'green') ? 'blue' : 'green'
          sh "kubectl -n ${K8S_NAMESPACE} scale deploy/demo-${oldColor} --replicas=0"
        }
      }
    }
  }
  post {
    always {
      sh "kubectl -n ${K8S_NAMESPACE} get svc,deploy,po -l app=demo -o wide || true"
    }
  }
}
