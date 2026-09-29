# =============================================================================
# Geral
# =============================================================================
variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto — usado como prefixo em todos os recursos"
  type        = string
  default     = "prova-devops"
}

# =============================================================================
# VPC
# =============================================================================
variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Lista de AZs (mínimo 2)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# =============================================================================
# Security Group
# =============================================================================
variable "allowed_ssh_cidrs" {
  description = "CIDRs permitidos para SSH (recomendado: seu IP /32)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# =============================================================================
# EC2
# =============================================================================
variable "ec2_instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome do Key Pair para SSH (deve existir na conta AWS Academy)"
  type        = string
}

variable "app_port" {
  description = "Porta da API"
  type        = number
  default     = 3000
}

# =============================================================================
# RDS
# =============================================================================
variable "rds_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Storage alocado para o RDS em GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "reservas_db"
}

variable "db_username" {
  description = "Usuário master do banco"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Senha master do banco"
  type        = string
  sensitive   = true
}
