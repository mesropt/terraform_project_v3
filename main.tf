# 1.1. Get EC2 AMI
# data - это запрос с клауду или провайдеру о ресурсах, которые мы хотим получить
# это более флексибл вариант для установки ami, так как в каждом регионе он свой и имеет свой айдишник, на будущее
# для других регионов тем самым мы не будем менять код
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

# 1.2. Declare EC2
resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.small"
  subnet_id = var.subnet_id
  associate_public_ip_address = true
#   vpc_security_group_ids = [aws_security_group.my_security_group.id]
#   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data = "${file("install_required_packages.sh")}"

  tags = var.common_tags
}


# если проект большой, то main.tf лучше разделять, например, на network.tf, instances.tf, loadbalancer.tf и так далее