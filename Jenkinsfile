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

        stage('Checkout Git Repository') {
            steps {
                script {
                    // Change to the directory, create if it doesn't exist
                    bat 'if not exist "%GIT_DIR%" mkdir "%GIT_DIR%"'

                    // Navigate to the directory
                    bat "cd %GIT_DIR%"

                    // Initialize Git repository if not already initialized
                    bat 'git rev-parse --is-inside-work-tree 2>nul || git init'

                    // Add the remote repository if not already added
                    bat 'git remote get-url origin 2>nul || git remote add origin %GIT_REPO%'

                    // Ensure the correct remote URL is set
                    bat 'git remote set-url origin %GIT_REPO%'

                    // Fetch the latest changes from the main branch
                    bat 'git fetch origin main'

                    // Check if the branch exists locally and reset or checkout as needed
                    bat '''
                    git show-ref --verify --quiet refs/heads/main && (
                        git reset --hard origin/main
                    ) || (
                        git checkout -b main origin/main
                    )
                    '''

                    // Pull the latest changes with rebase
                    bat 'git pull origin main --rebase'
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
