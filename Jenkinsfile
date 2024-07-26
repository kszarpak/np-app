def frontendImage="kszarpak/frontend"
def backendImage="kszarpak/backend"

pipeline {
    agent {
        label 'agent'
    }

    environment {
        PIP_BREAK_SYSTEM_PACKAGES = 1
    }
   
    parameters {
        string(name: 'backendDockerTag', defaultValue: 'latest', description: 'Backend docker image tag')
        string(name: 'frontendDockerTag', defaultValue: 'latest', description: 'Frontend docker image tag')
    }

    stages {
        stage('Get Code') {
            steps {
                checkout scm // Get some code from a GitHub repository
            }
        }

        stage('Show version') {
            steps {
                script{
                    currentBuild.description = "Backend: ${backendDockerTag}, Frontend: ${frontendDockerTag}"
                }
            }
        }

        stage('Clean running containers') {
            steps {
                sh "docker rm -f frontend backend"
            }
        }

        stage('Deploy application') {
            steps {
                script {
                    withEnv(["FRONTEND_IMAGE=$frontendImage:$frontendDockerTag",
                             "BACKEND_IMAGE=$backendImage:$backendDockerTag"]) {
                        sh "docker-compose up -d"
                    }
                }
            }
        }

        stage('Selenium tests') {
            steps {
                sh "pip3 install -r requirements.txt"
                sh "python3 -m pytest frontendTest.py"
            }
        }
    }
    
    post {
        success {
            input message: 'Do you want to proceed with the deployment?', ok: 'Yes'
            build job: 'deploy', 
                  parameters: [
                      string(name: 'backendDockerTag', value: params.backendDockerTag),
                      string(name: 'frontendDockerTag', value: params.frontendDockerTag)
                  ],
                  wait: false
        }
        always {
            sh "docker-compose down"
            cleanWs()
        }
    }
}
