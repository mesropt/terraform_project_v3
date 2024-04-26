terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "qnt-clouds-for-pe-tfstate"
    key    = "mesrop_tarkhanyan/terraform.tfstate"
    region = "us-east-2"
  }
}

# Configure the AWS Provider
provider "aws" {
  alias      = "aws_us_east_2"
  region     = "us-east-2"
  access_key = var.access_key
  secret_key = var.secret_key
}