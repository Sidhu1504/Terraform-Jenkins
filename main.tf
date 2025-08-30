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
	 ami = "ami-0cfde0ea8edd312d4"
	 instance_type = "t3.micro"
	 associate_public_ip_address = true
	 key_name = "sidhu"
	 count = 1
	  tags = {
    Name = "tf-example"
  }
} 

