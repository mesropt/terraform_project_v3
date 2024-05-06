# Если проект большой, то main.tf лучше разделять, например, на network.tf, instances.tf, loadbalancer.tf и т.д.

# 1.1. Get EC2 AMI
# data - это запрос к облаку или провайдеру о ресурсах, которые мы хотим получить. Это более гибкое решение
# для установки ami, так как в каждом регионе ami свой и, соответственно, имеется свой id. В результате в будущем
# для других регионов мы не будем менять код.
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

# 2.2. Declare EC2 instance
resource "aws_instance" "my_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3a.small"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_allow_inbound_ssh_22_http_80_outbound_anywhere_v2_tf.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile_tf.name
  user_data                   = file("install_required_packages.sh")

  tags = merge(
    var.common_tags,
    {
      Name = "ec2_mesrop_tarkhanyan_terraform"
    }
  )
}

# 2.3. Declare Security Group
resource "aws_security_group" "sg_allow_inbound_ssh_22_http_80_outbound_anywhere_v2_tf" {
  name        = "sg_allow_inbound_ssh_22_http_80_outbound_anywhere_v2_aws"
  description = "Security group to allow inbound SSH access from my IP address to port 22 and allow inbound HTTP traffic to port 80 from any location. Outbound traffic is allowed to anywhere."
  vpc_id      = "vpc-024cf058980b63412"
  #   depends_on = [aws_instance.my_ec2]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "sg_mesrop_tarkhanyan_terraform"
  })
}

# 2.4. Declare S3 bucket
# resource "aws_s3_bucket" "my_new_bucket" {
#   bucket = data.aws_s3_bucket.my_bucket_data.id
#   tags = var.common_tags
# }

data "aws_s3_bucket" "my_bucket" {
  bucket = "qnt-bucket-tf-mesrop-tarkhanyan"
}

# 2.5 Declare Role with policy to access the S3 bucket
# 2.5.1. Declare IAM policy
resource "aws_iam_policy" "s3_full_access_policy_tf" {
  name        = "s3_full_access_policy_aws"
  description = "Policy grants full access to specific S3 bucket"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::qnt-bucket-tf-mesrop-tarkhanyan", "arn:aws:s3:::qnt-bucket-tf-mesrop-tarkhanyan/*"]
      },
    ]
  })
}

# 2.5.2. Declare IAM role
resource "aws_iam_role" "s3_full_access_role_tf" {
  name = "s3_full_access_role_aws"

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

  tags = var.common_tags
}

# 2.5.3. Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_s3_full_access_policy_tf_to_iam_role_tf" {
  role       = aws_iam_role.s3_full_access_role_tf.name
  policy_arn = aws_iam_policy.s3_full_access_policy_tf.arn
}

# 2.5.4. Attach the IAM role to the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile_tf" {
  name = "ec2_profile_aws"
  role = aws_iam_role.s3_full_access_role_tf.name
}
