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

resource "aws_instance" "myinstance" {
  ami                         = "ami-0cfde0ea8edd312d4"  # Make sure this is Ubuntu 24 AMI
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = "sidhu"
  count                       = 1

  tags = {
    Name = "tf-example"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update packages
              sudo apt update -y
              sudo apt upgrade -y

              # Install Java (OpenJDK 17)
              sudo apt install openjdk-17-jdk -y

              # Add Jenkins repo and key
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
                  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                  /etc/apt/sources.list.d/jenkins.list > /dev/null

              # Update and install Jenkins
              sudo apt update -y
              sudo apt install jenkins -y

              # Start Jenkins service and enable at boot
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}

