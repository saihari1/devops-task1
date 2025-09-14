pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Setup Environment') {
            steps {
                sh '''
                    # Update system
                    sudo yum update -y

                    # Install Git, Docker, and required utils
                    sudo yum install -y git docker yum-utils shadow-utils
                    sudo systemctl start docker
                    sudo systemctl enable docker

                    # Install Terraform repo and Terraform
                    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
                    sudo yum install -y terraform

                    # Install NVM & Node.js
                    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
                    . ~/.nvm/nvm.sh
                    nvm install 22
                    nvm use 22

                    # Verify installs
                    git --version
                    docker --version
                    terraform version
                    node -v
                    npm -v
                '''
            }
        }

        stage('Clone Repository') {
            steps {
                sh '''
                    rm -rf devops-task1
                    git clone -b main https://github.com/saihari1/devops-task1.git
                    cd devops-task1
                    ls -l
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    . ~/.nvm/nvm.sh
                    cd devops-task1
                    npm install
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockercred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    cd devops-task1
                    sudo docker build -t saihari1/devopstask .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    sudo docker push saihari1/devopstask
                '''
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir('devops-task1') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh 'terraform destroy -auto-approve || true'
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('devops-task1') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('devops-task1') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('devops-task1') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }
}
