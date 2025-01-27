# Jenkins Pipeline: Terraform + Ansible + AWS CodeDeploy  
Automate the deployment of an EC2 instance, configure Nginx, and deploy a static website using Jenkins, Terraform, Ansible, and AWS CodeDeploy.  

## Project Workflow  
1️⃣ Terraform → Creates a Security Group & launches an EC2 instance.  
2️⃣ Ansible → Installs and configures Nginx on the instance.  
3️⃣ AWS CodeDeploy → Deploys a static HTML website.  

📦 Jenkins-Terraform-Ansible-CodeDeploy  
├── 📜 README.md  
├── 📜 Jenkinsfile  
├── terraform/  
│   ├── 📜 main.tf  
│   ├── 📜 terraform.tfvars  
│   ├── 📜 outputs.tf  
├── ansible/  
│   ├── 📜 install_nginx.yaml  
│   ├── 📜 hosts.ini  
├── codedeploy/  
│   ├── 📜 appspec.yml  
│   ├── 📜 scripts/start_server.sh  
│   ├── 📜 index.html  
