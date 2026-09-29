variable "project_name" {
  description = "Nome do projeto usado como prefixo nos recursos"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "ID da subnet pública onde a EC2 será criada"
  type        = string
}

variable "security_group_id" {
  description = "ID do Security Group da EC2"
  type        = string
}

variable "key_name" {
  description = "Nome do Key Pair para acesso SSH (deve existir na conta)"
  type        = string
}

variable "app_port" {
  description = "Porta em que a API escuta"
  type        = number
  default     = 3000
}

# Variáveis de conexão com o RDS (alimentadas pelo módulo rds)
variable "db_host" {
  description = "Endpoint do RDS PostgreSQL"
  type        = string
}

variable "db_port" {
  description = "Porta do banco de dados"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_user" {
  description = "Usuário do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
