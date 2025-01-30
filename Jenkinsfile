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
                    bat 'dir'
                    bat 'wsl pwd'            // Print WSL working directory
                    bat 'wsl ansible --version' // Check Ansible
                    bat 'wsl dir'
                    bat 'wsl bash -c "cd ansible && pwd && dir && ansible-playbook -i hosts.ini install_nginx.yaml"'
                }
            }
        }
    }
}
