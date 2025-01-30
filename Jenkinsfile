pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')  
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')  
        EC2_PUBLIC_IP = ""
        GIT_REPO = 'https://github.com/gitsaravanesh/aws-auto-deploy-project.git'
        GIT_DIR = '/root/ansible-proj'
    }
    
    stages {

        stage('Checkout Git Repository') {
            steps {
                script {
                    try {
                        sh 'wsl --version'       // Ensure WSL is available
                        sh 'wsl uname -r'       // Check WSL Kernel version
                        sh 'wsl pwd'            // Print WSL working directory
                        sh 'wsl ansible --version' // Check Ansible
                    } catch (Exception e) {
                        echo "WSL is not available: ${e}"
                    }
                }
            }
        }
    }
