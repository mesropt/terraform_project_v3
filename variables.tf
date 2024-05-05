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
  default     = {
    env = "Dev"
    owner = "Mesrop Tarkhanyan"
    project = "CE_for_PE"
}
  description = "Default Tags for all resources"
  type        = map(string)
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
  default     = "subnet-07549c87757e073ea"
}