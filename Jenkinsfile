pipeline {
    agent any

    tools {
        maven 'Maven-3'
    }

    environment {
        AWS_REGION = 'ap-south-1'
        ACCOUNT_ID = '042729137733'
        IMAGE_NAME = 'springboot-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        REPOSITORY = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
        SERVER = '3.108.41.200'
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/avadutpatil823/java-web-app.git'
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Verify WAR File') {
            steps {
                sh 'ls -lh target/'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build \
                -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                sh """
                aws ecr get-login-password --region ${AWS_REGION} | \
                docker login \
                --username AWS \
                --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh """
                docker tag \
                ${IMAGE_NAME}:${IMAGE_TAG} \
                ${REPOSITORY}:${IMAGE_TAG}

                docker tag \
                ${IMAGE_NAME}:${IMAGE_TAG} \
                ${REPOSITORY}:latest
                """
            }
        }

        stage('Push Image to Amazon ECR') {
            steps {
                sh """
                docker push ${REPOSITORY}:${IMAGE_TAG}
                docker push ${REPOSITORY}:latest
                """
            }
        }

        stage('Deploy to Application EC2') {
            steps {

                sshagent(credentials: ['application-server']) {

                    sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@${SERVER} '

                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login \
                    --username AWS \
                    --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    docker pull ${REPOSITORY}:latest

                    docker stop java-web-app || true

                    docker rm java-web-app || true

                    docker image prune -f

                    docker run -d \
                        --name java-web-app \
                        --restart always \
                        -p 8080:8080 \
                        ${REPOSITORY}:latest

                    docker ps

                    '
                    """
                }
            }
        }

        stage('Deployment Verification') {
            steps {
                sh """
                curl -I http://${SERVER}:8080 || true
                """
            }
        }
    }

    post {

        success {

            echo "========================================="
            echo "BUILD SUCCESSFUL"
            echo "Application Deployed Successfully"
            echo "Application URL : http://${SERVER}:8080"
            echo "========================================="
        }

        failure {

            echo "========================================="
            echo "BUILD FAILED"
            echo "Please check Jenkins Console Output"
            echo "========================================="
        }

        always {

            cleanWs()
        }
    }
}
