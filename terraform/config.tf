terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # 2.1. Declare remote state backend in s3
  # Backend (state файла лучше хранить удалённо, например в s3)
  backend "s3" {
    bucket  = "qnt-clouds-for-pe-tfstate"
    key     = "user_homework_1/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true # рекомендуется, так как state файл может хранить чувствительную информацию
    # dynamodb_table = "terraform-state-lock-app" # чтобы state файл одновременно редактировал только один
    # пользователь, но dynamodb_table должна быть создана заранее, так как terraform сам его не создаст
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-2"
  access_key = var.access_key
  secret_key = var.secret_key
}
