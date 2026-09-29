variable "aws_region" {
  description = "Região AWS onde o bucket e a tabela serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "prova-devops"
}

variable "state_bucket_name" {
  description = "Nome único do bucket S3 para armazenar o terraform state"
  type        = string
  # Nomes de bucket S3 são globalmente únicos — ajuste conforme necessário
  default     = "prova-devops-terraform-state"
}

variable "lock_table_name" {
  description = "Nome da tabela DynamoDB para locking do state"
  type        = string
  default     = "prova-devops-terraform-lock"
}
