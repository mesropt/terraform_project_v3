Get EC2 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Declare EC2
resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.small"
  subnet_id = "07549c87757e073ea"
  associate_public_ip_address = true
  user_data = "
  #! /bin/bash
  sudo apt update
  sudo apt install -y nginx
  "
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Owner = "Mesrop Tarkhanyan"
  }
}

# Declare Security Group
resource "aws_security_group" "my_security_group" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {

}

  egress {

}

  tags = {
    Owner = "Mesrop Tarkhanyan"
  }
}

# Declare S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "qnt-bucket-tf-mesrop-tarkhanyan"

  tags = {
    Owner     = "Mesrop Tarkhanyan"
  }
}

# Declare Role
resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}