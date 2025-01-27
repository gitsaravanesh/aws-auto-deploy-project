pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        EC2_PUBLIC_IP = ""
    }
    
    stages {
        
        stage('Setup AWS Credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    script {
                    def awsCheck = sh(script: "aws sts get-caller-identity", returnStdout: true).trim()
                    if (!awsCheck.contains("Account")) {
                        error("AWS credentials are invalid! Please check AWS CLI configuration in Jenkins.")
                    }
                    echo "AWS Credentials are valid: ${awsCheck}"
                    '''
                }
            }
        }
        
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
        
        stage('Terraform') {
            steps {
                script {
                    bat '''
                        cd terraform
                        terraform init
                        terraform apply -auto-approve
                        terraform output -raw public_ip > ec2_public_ip.txt
                    '''
                    def ec2Ip = readFile('ec2_public_ip.txt').trim()
                    env.EC2_PUBLIC_IP = ec2Ip
                }
            }
        }

        stage('Ansible') {
            steps {
                script {
                    bat '''
                        echo [all] > hosts.ini
                        echo %EC2_PUBLIC_IP% >> hosts.ini
                        ansible-playbook -i hosts.ini install_nginx.yaml --key-file ~/.ssh/my-key.pem
                    '''
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
