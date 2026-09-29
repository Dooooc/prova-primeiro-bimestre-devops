terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote State: S3 + DynamoDB (criados pelo infra/backend)
  backend "s3" {
    bucket         = "prova-devops-terraform-state"
    key            = "prova-devops/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "prova-devops-terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region
}
