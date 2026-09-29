output "db_endpoint" {
  description = "Endpoint de conexão do RDS (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_host" {
  description = "Host do RDS (sem porta)"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.this.db_name
}
