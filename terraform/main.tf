provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami             = "ami-023a307f3d27ea427" # Change based on your region
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_http.name]
  key_name        = "ansible-key"

  tags = {
    Name = "Terraform-Jenkins-EC2"
  }
}
