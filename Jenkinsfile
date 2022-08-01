#!groovy
pipeline {
    agent any
    stages {           
        stage('Build app') {
            steps {
                sh 'docker build -t hello-devops:latest -f Dockerfile .'}
            }
        stage('tagging the image') {
            steps {
                sh 'docker tag hello-devops:latest abdelrahman1111/grad-proj:hello-devops'}
            }
        stage('Docker push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'hamada', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
                    sh 'docker push abdelrahman1111/grad-proj:hello-devops'   }
                }
            }
        stage('app deploy') {
            steps {
                sh 'kubectl apply -Rf ./app-yamls' }
            }
        }
    }
