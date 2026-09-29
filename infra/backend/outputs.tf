output "state_bucket_name" {
  description = "Nome do bucket S3 para o backend do Terraform"
  value       = var.state_bucket_name
}

output "lock_table_name" {
  description = "Nome da tabela DynamoDB para locking"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "backend_config" {
  description = "Bloco backend para referência no providers.tf"
  value       = <<-EOT
    backend "s3" {
      bucket         = "${var.state_bucket_name}"
      key            = "prova-devops/terraform.tfstate"
      region         = "${var.aws_region}"
      encrypt        = true
      dynamodb_table = "${aws_dynamodb_table.terraform_lock.name}"
    }
  EOT
}
