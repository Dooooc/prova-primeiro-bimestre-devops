# =============================================================================
# Backend — DynamoDB para locking do remote state
#
# NOTA: O bucket S3 "prova-devops-terraform-state" foi criado manualmente
# no console AWS Academy pois o SCP da organização bloqueia
# s3:GetBucketObjectLockConfiguration via Terraform.
# O bucket já existe com versionamento e encriptação AES-256 habilitados.
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

# =============================================================================
# DynamoDB Table — locking do state (evita apply simultâneo)
# =============================================================================
resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = var.lock_table_name
    Project   = var.project_name
    ManagedBy = "terraform-backend"
  }
}
