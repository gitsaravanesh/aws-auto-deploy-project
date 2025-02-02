pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')  
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')  
        EC2_PUBLIC_IP = ""
        GIT_REPO = 'https://github.com/gitsaravanesh/aws-auto-deploy-project.git'
        GIT_DIR = '/root/ansible-proj'
        S3_BUCKET = 'codedeploy-auto-s3'
        S3_FILE = 'program.zip'
        LOCAL_FILE = 'index.html'
        DEPLOYMENT_GROUP = 'terra-ansi-auto'
        APPLICATION_NAME = 'terra-ansi-auto'
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
                script {                
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
        }

        stage('Move Files') {
            steps {
                script {
                    bat """
                        set SOURCE_FILE=C:\\Users\\raja4\\.jenkins\\workspace\\ansible-terrafo-auto\\terraform\\hosts.ini
                        set TARGET_DIR=C:\\Users\\raja4\\.jenkins\\workspace\\ansible-terrafo-auto\\ansible

                        if exist "%SOURCE_FILE%" (
                            move /Y "%SOURCE_FILE%" "%TARGET_DIR%"
                            echo hosts.ini moved successfully!
                        ) else (
                            echo hosts.ini not found!
                        )
                    """
                }
            }
        }
        
        stage('Ansible') {
            steps {
                script {
                    bat """
                        wsl bash -c "export ANSIBLE_HOST_KEY_CHECKING=False && \
                        cd ansible && pwd && ls -l && \
                        ansible-playbook -i hosts.ini install_nginx.yaml \
                        --private-key=/root/.ssh/ansible-key.pem \
                        -e 'ansible_user=ubuntu ansible_ssh_common_args=\\\"-o StrictHostKeyChecking=no\\\"'"
                    """
                    }
                }
             }

        stage('CodeDeploy') {
            steps {
                script {
                    powershell """
                        \$LOCAL_FILE = '${LOCAL_FILE}'
                        \$S3_FILE = '${S3_FILE}'
                        cd codedeploy
                        Compress-Archive -Path \$LOCAL_FILE -DestinationPath \$S3_FILE
                    """
                    bat 'cd codedeploy && aws s3 cp ${S3_FILE} s3://${S3_BUCKET}/${S3_FILE}'
                    
                    def deployment = bat(script: """
                        cd codedeploy
                        aws deploy create-deployment ^
                            --application-name ${APPLICATION_NAME} ^
                            --deployment-group-name ${DEPLOYMENT_GROUP} ^
                            --revision "revisionType=S3,s3Location={bucket=${S3_BUCKET},key=${S3_FILE},bundleType=zip}" ^
                            --deployment-config-name CodeDeployDefault.OneAtATime ^
                            --description "Deploy simple HTML"
                    """, returnStdout: true).trim()

                    // Extract the deployment ID from the response
                    def deploymentId = deployment.split(' ')[1]

                    // Wait for the deployment to complete
                    bat """
                        cd codedeploy
                        aws deploy get-deployment --deployment-id ${deploymentId}
                    """
                }
            }
        }
    }
 }
