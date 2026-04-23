pipeline {
    agent any

    tools {
        jdk 'jdk11'
        maven 'maven3'
    }

    environment {
        SONAR_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = "venky005/cicd-byme"
    }

    triggers {
        pollSCM('* * * * *')   // every minute (for demo; don’t use in real life)
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/venkat8977/CI-CD-byme.git',
                    credentialsId: 'github-token'
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
                    sh '''
                    $SONAR_HOME/bin/sonar-scanner \
                    -Dsonar.projectKey=cicd-byme \
                    -Dsonar.projectName=cicd-byme \
                    -Dsonar.sources=src \
                    -Dsonar.java.binaries=target
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t venky005/cicd-byme:latest .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'docker-cred', url: 'https://index.docker.io/v1/']) {
                    sh 'docker push venky005/cicd-byme:latest'
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker stop cicd-container || true
                docker rm cicd-container || true
                docker run -d -p 8081:8080 --name cicd-container $DOCKER_IMAGE
                '''
            }
        }
    }
}