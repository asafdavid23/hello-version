pipeline {
    agent none
    stages {
        stage('Install Node Modules') {
            agent {
                docker 'node:17.7.2-alpine' 
            }
            steps {
                echo "Building ${env.JOB_NAME}..."
                sh 'yarn install'
            }
        }
        stage('Build Docker Image') {
            agent { 
                node { 
                    label 'master' 
                } 
            }
            steps {
                script {
                    try {
                        sh "echo 'Building Docker Image'"
                        sh 'docker build . -t web-app'
                    } catch (e) {
                        echo 'Failed to build Docker Image'
                        currentBuild.result = "FAILED"
                        throw e
                    }
                }
            }
        }
        stage('Push') {
            agent { 
                node { 
                    label 'master' 
                } 
            }
            steps {
                script {
                    sh "echo 'Pushing Docker Image'"
                    sh '''docker login -u _json_key -p "$(cat /opt/keyfile.json)" https://eu.gcr.io'''
                    sh '''docker tag web-app eu.gcr.io/qwilt-candidate/web-app:$(git rev-parse --short HEAD)'''
                    sh '''docker push eu.gcr.io/qwilt-candidate/web-app:$(git rev-parse --short HEAD)'''
                }
            }
        }
        stage('Deploy') {
            agent { 
                node { 
                    label 'master' 
                } 
            }
            steps {
                script {
                    sh "echo 'Deploying Helm Chart'"
                    sh 'gcloud container clusters get-credentials asaf-gke-cluster --zone europe-west3-a --project qwilt-candidate'
                    sh '''cd charts/ && helm upgrade web-app ./ -n web-app --set image.tag=$(git rev-parse --short HEAD)'''
                }
            }
        }
    }
}
