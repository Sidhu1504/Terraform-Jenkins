terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# Security Group for EC2
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# EC2 Instance
resource "aws_instance" "myinstance" {
  ami                         = "ami-0cfde0ea8edd312d4"  # Ubuntu 24 AMI
  instance_type               = "t3.micro"
  key_name                    = "sidhu"
  associate_public_ip_address = true
  count                       = 1
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "tf-jenkins-ubuntu24"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update and upgrade
              sudo apt update -y
              sudo apt upgrade -y

              # Install Java 17 (recommended for Jenkins)
              sudo apt install openjdk-17-jdk -y
              java -version

              # Create keyrings directory if not exists
              sudo mkdir -p /etc/apt/keyrings

              # Add Jenkins repository and key
              sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

              # Update and install Jenkins
              sudo apt update -y
              sudo apt install jenkins -y

              # Start Jenkins service and enable at boot
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}
