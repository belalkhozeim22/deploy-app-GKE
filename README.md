# deploy-app-GKE
Now after setting up the jenkins pods and grant him the needed permission, i can create my pipeline to build the application and push the image to my dockerhub then deploy it on the cluster.
So i am gonna explain that in steps 
## Build the app
- I built an application eng.mahmoud alaa gives as its code using Docker file 
[The code repo](https://github.com/mahmoud254/jenkins_nodejs_example.git)
```
FROM node:12
COPY nodeapp /nodeapp
WORKDIR /nodeapp
RUN npm install
CMD ["node", "/nodeapp/app.js"]
```
## Creating a repo 
- Now to push this image on my dockerhub i created a new repo 
![image](https://user-images.githubusercontent.com/104630009/182244436-cdd6bad4-8911-448d-a9f9-63c7c8b1b293.png)

## Authorize jenkins to push my image
- Ofcourse to push the built image to my image jenkins needs authorization so i create a credentials for it using my username and password
![image](https://user-images.githubusercontent.com/104630009/182245014-f7f259f6-991c-413e-aa63-d766e6140d20.png)

## Creating my app yaml files
- I created a deployment yaml file to create my app deployment later on in the pipeline
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodeapp
  namespace: prod
  labels: 
    app: nodeapp
spec:
  replicas: 3
  selector: 
    matchLabels:
      app: nodeapp
  template:
    metadata:
      labels:
        app: nodeapp
    spec:
      containers:
      - name: nodeapp
        image: abdelrahman1111/grad-proj:hello-devops
        ports:
        - containerPort: 3000

```
- And ofcourse a service of type loadbalancer to expose it on port 3000
```
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: prod
  annotations:
        cloud.google.com/load-balancer-type: "External"
spec:
  selector:
    app: nodeapp
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
```

## Creating the Jenknsfile
- As i am gonna create my pipeline using SCM i need to create a jenkins file in my repo so i created a Jenkinsfile with four stage 
1. Stage **build app** to build the using `docker build`
2. Stage **tagging the image** to tag th image to be able to push it to my dockerhub repo 
3. Stage **push the image** to push my tagged image using my created credentials 
4. Stage **app deploy** to create the app deployment and app service using `kubectl apply` command 

```
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
        stage('push the image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerhubAuth', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
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

```
## Creating the pipeline 
![image](https://user-images.githubusercontent.com/104630009/182246699-df52a4cd-4318-4b40-9634-c14d1b008036.png)

## build the pipeline 
![Screenshot from 2022-08-01 21-19-39](https://user-images.githubusercontent.com/104630009/182247075-12992097-6f0c-4fb7-995c-e6630f495ebf.png)
- Making sure everything is working as it should be
![Screenshot from 2022-08-01 21-21-33](https://user-images.githubusercontent.com/104630009/182247237-13ae3125-4f99-4309-be15-c99f64077856.png)


![Screenshot from 2022-08-01 21-21-24](https://user-images.githubusercontent.com/104630009/182247257-eed67905-916b-4500-ab4a-823d1d8b5986.png)
- Both service and deployment are working great, just wait a few seconds til my loadbalancer be ready and take its external IP and test it on my browser on port 300 and it works!

![Screenshot from 2022-08-01 21-19-48](https://user-images.githubusercontent.com/104630009/182247477-4ab7beee-98b5-44ff-979d-c1f012b6cb9d.png)


