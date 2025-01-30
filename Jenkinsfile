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
                    bat 'wsl --version'       // Ensure WSL is installed
                    bat 'wsl uname -r'       // Check WSL Kernel version
                    bat 'wsl pwd'            // Print WSL working directory
                    bat 'wsl ansible --version' // Check Ansible
                    bat 'wsl bash -c "cd /home/ansible-proj/ansible && pwd && ls -l"'
                }
            }
        }
    }
}
