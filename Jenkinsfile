pipeline {
    agent any

    environment {
        // Define values as environment variables for better maintainability
        CLUSTER_NAME = 'my-cluster1'
        ZONE = 'us-west3'
        PROJECT_ID = 'satyanarayana'
        GIT_BRANCH = 'main'
        DEPLOYMENT_NAME = 'flask-app-deployment' // Name of your deployment
        NAMESPACE = 'default' // You can change this if you're using a different namespace
    }

    stages {
        stage('Git Checkout') {
            steps {
                // Checkout the repository using the defined branch
                git url: 'https://github.com/satya-git07/Final-project-.git', branch: "${GIT_BRANCH}"
            }
        }

        stage("Docker Build & Push") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-credentials', toolName: 'docker') {   
                        sh "docker build -t flask ."
                        sh "docker tag flask:latest satyadockerhub07/flask:tagname"
                        sh "docker push satyadockerhub07/flask:tagname"
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                // Authenticate and apply Terraform changes
                withCredentials([file(credentialsId: 'gcp-sa', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy to GKE') {
            steps {
                // Authenticate and deploy to GKE
                withCredentials([file(credentialsId: 'gcp-sa', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    script {
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                        sh "gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID}"
                        sh 'kubectl apply -f deploy.yaml'
                    }
                }
            }
        }

        stage('Check Deployment Status') {
            steps {
                script {
                    // Check the deployment status and wait for a successful rollout
                    def rolloutStatus = sh(script: "kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}", returnStatus: true)
                    
                    // If the rollout fails, trigger a rollback
                    if (rolloutStatus != 0) {
                        echo "Deployment failed. Triggering rollback."
                        sh "kubectl rollout undo deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}"
                    } else {
                        echo "Deployment successful."
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Clean workspace after each run
        }

        success {
            echo "Deployment successful and stable."
        }

        failure {
            echo "Deployment failed. Rollback completed if necessary."
        }
    }
}
