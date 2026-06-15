pipeline {
agent any

```
tools {
    jdk 'jdk11'
    maven 'maven3'
}

environment {
    SONAR_HOME = tool 'sonar-scanner'
    IMAGE_NAME = "venky005/cicd-byme"
    IMAGE_TAG = "${BUILD_NUMBER}"
}

triggers {
    pollSCM('* * * * *')
}

stages {

    stage('Checkout Code') {
        steps {
            git branch: 'main',
                url: 'https://github.com/venkat8977/CI-CD-byme.git',
                credentialsId: 'github-cred'
        }
    }

    stage('Build (Maven)') {
        steps {
            sh 'mvn clean package'
        }
    }

    stage('SonarQube Analysis') {
        steps {
            withSonarQubeEnv('sonar-server') {
                sh """
                ${SONAR_HOME}/bin/sonar-scanner \
                -Dsonar.projectKey=cicd-byme \
                -Dsonar.projectName=cicd-byme \
                -Dsonar.sources=src \
                -Dsonar.java.binaries=target
                """
            }
        }
    }

    stage('Quality Gate') {
        steps {
            timeout(time: 5, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
            }
        }
    }

    stage('Build Docker Image') {
        steps {
            sh """
            docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
            """
        }
    }

    stage('Push Docker Image') {
        steps {
            withDockerRegistry(
                [credentialsId: 'docker-cred',
                 url: 'https://index.docker.io/v1/']) {

                sh """
                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                docker push ${IMAGE_NAME}:latest
                """
            }
        }
    }

    stage('Deploy Container') {
        steps {
            sh """
            docker stop cicd-container || true
            docker rm cicd-container || true

            docker run -d \
              -p 8081:8080 \
              --name cicd-container \
              ${IMAGE_NAME}:${IMAGE_TAG}
            """
        }
    }

    stage('Update Manifest') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'github-cred',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_TOKEN'
                )
            ]) {

                sh """
                sed -i 's|image: .*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml

                git config user.email 'jenkins@example.com'
                git config user.name 'jenkins'

                git add k8s/deployment.yaml

                git commit -m 'Update image ${IMAGE_TAG}' || true

                git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@github.com/venkat8977/CI-CD-byme.git

                git push origin main
                """
            }
        }
    }
}

post {
    success {
        echo 'Pipeline completed successfully'
    }

    failure {
        echo 'Pipeline failed'
    }
}
```

}
