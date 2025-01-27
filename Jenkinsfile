pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        EC2_PUBLIC_IP = ""
    }

    stages {
        stage('Terraform') {
            steps {
                script {
                    sh '''
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
                    sh '''
                        echo "[all]\n${EC2_PUBLIC_IP}" > hosts.ini
                        ansible-playbook -i hosts.ini install_nginx.yaml --key-file ~/.ssh/my-key.pem
                    '''
                }
            }
        }

        stage('CodeDeploy') {
            steps {
                script {
                    sh '''
                        aws deploy create-deployment \
                            --application-name MyApp \
                            --deployment-group-name MyDeploymentGroup \
                            --deployment-config-name CodeDeployDefault.OneAtATime \
                            --github-location repository=my-github-repo,commitId=latest
                    '''
                }
            }
        }
    }
}
