variable "access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  default = {
    env     = "dev"
    owner   = "mesrop.tarkhanyan@quantori.com"
    project = "INFRA"
  }
  description = "Default Tags for all resources"
  type        = map(string)
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
  default     = "subnet-07549c87757e073ea"
}

variable "my_ip" {
  description = "My public IP address for secure SSH access"
  type        = string
  default     = "165.225.200.126/32"
}