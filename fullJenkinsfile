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

         stage('Checkout Code') {
            steps {
                script {
                    checkout scmGit(
                        branches: [[name: '*/main']],
                        extensions: [],
                        userRemoteConfigs: [[
                            credentialsId: '99b02a4c-674b-4f86-a8d4-268000c947a9',
                            url: 'https://github.com/gitsaravanesh/aws-auto-deploy-project'
                        ]]
                    )
                }
                bat 'dir'  // List files to verify checkout
            }
        }
        
        stage('Setup AWS Credentials') {
            steps {
            withCredentials([
                string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
            ]) {
                bat '''
                set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
                set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
                '''
                }
            }
        }
        
        stage('Terraform') {
            steps {
                script {
                    bat '''
                        cd terraform
                        terraform init
                        terraform apply -auto-approve
                        '''
                }
            }
        }

        stage('Generate Hosts File') {
            steps {
                bat '''
                    cd terraform
                    terraform output -raw public_ip > ec2_public_ip.txt
                    type ec2_public_ip.txt
                    echo [all] > hosts.ini
                    type hosts.ini
                    type ec2_public_ip.txt >> hosts.ini
                    type hosts.ini
                '''
            }
        }

        stage('Checkout Git Repository') {
            steps {
                script {
                    // Check if the directory exists, create it if it doesn't using WSL
                    sh 'wsl if [ ! -d "$GIT_DIR" ]; then mkdir -p "$GIT_DIR"; fi'

                    // Navigate to the directory and initialize the git repo if necessary
                    sh '''
                    wsl "cd $GIT_DIR && git rev-parse --is-inside-work-tree 2>/dev/null || git init"
                    wsl "cd $GIT_DIR && git remote get-url origin 2>/dev/null || git remote add origin $GIT_REPO"
                    wsl "cd $GIT_DIR && git fetch origin main"
                    wsl "cd $GIT_DIR && git pull origin main --rebase"
                    '''
                }
                }
            }

        stage('Move Files to WSL') {
            steps {
                script {
                    bat 'dir'
                    bat 'wsl -e bash -c "ansible --version"'
                    bat wsl 'git remote get-url origin 2>/dev/null || git remote add origin https://github.com/gitsaravanesh/aws-auto-deploy-project.git'
                    bat 'wsl git remote -v'
                    bat 'wsl git pull origin main --rebase'
                    bat 'dir'
                }
            }
        }
        
        stage('Ansible') {
            steps {
                script {
                    bat 'wsl ansible-playbook -i hosts.ini install_nginx.yaml'
                }
            }
        }

        stage('CodeDeploy') {
            steps {
                script {
                    bat '''
                        aws deploy create-deployment ^
                            --application-name MyApp ^
                            --deployment-group-name MyDeploymentGroup ^
                            --deployment-config-name CodeDeployDefault.OneAtATime ^
                            --github-location repository=my-github-repo,commitId=latest
                    '''
                }
            }
        }
    }
}
