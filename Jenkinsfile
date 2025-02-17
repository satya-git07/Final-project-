pipeline {
    agent any

    environment {
        // Define values as environment variables for better maintainability
        CLUSTER_NAME = 'my-cluster1'
        ZONE = 'us-west3'
        PROJECT_ID = 'satyanarayana'
        GIT_BRANCH = 'main'
        IMAGE_TAG = 'v1.0'  // You can dynamically set this as a variable or tag based on the commit.
        PREVIOUS_IMAGE_TAG = 'v0.9'  // You can store and use this to perform a rollback
    }

    stages {
        stage('Git Checkout') {
            steps {
                // Checkout the repository using the defined branch
                git url: 'https://github.com/satya-git07/Final-project-.git', branch: "${GIT_BRANCH}"
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
                        
                        // Deploy using kubectl, this is where the application gets deployed
                        sh "kubectl apply -f deploy.yaml"
                    }
                }
            }
        }
        stage('Health Check') {
            steps {
                script {
                    // This step will check if the application is healthy after deployment
                    def healthy = sh(script: "kubectl get pods --selector=app=my-flask-app -o jsonpath='{.items[0].status.containerStatuses[0].ready}'", returnStatus: true)
                    if (healthy != 0) {
                        error "Deployment failed, triggering rollback"
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                echo "Deployment was successful."
            }
        }

        failure {
            script {
                echo "Deployment failed. Rolling back to previous version."
                withCredentials([file(credentialsId: 'gcp-sa', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    // Rollback: Deploy the previous stable version using kubectl
                    sh "gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS"
                    sh "gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID}"

                    // Rollback to the previous image
                    sh "kubectl set image deployment/my-flask-app my-flask-app=gcr.io/my-project/my-flask-app:${PREVIOUS_IMAGE_TAG}"

                    // Optionally, monitor the rollback (you can add checks for the rollback status)
                    echo "Rollback to previous version completed."
                }
            }
        }

        always {
            cleanWs()
        }
    }
}
