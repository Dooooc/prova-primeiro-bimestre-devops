# =============================================================================
# Outputs úteis — exibidos após terraform apply
# =============================================================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "IP público da EC2"
  value       = module.ec2.public_ip
}

output "api_url" {
  description = "URL de acesso à API"
  value       = module.ec2.api_url
}

output "rds_endpoint" {
  description = "Endpoint completo do RDS (host:port)"
  value       = module.rds.db_endpoint
}

output "rds_host" {
  description = "Host do RDS"
  value       = module.rds.db_host
}

output "ec2_sg_id" {
  description = "ID do Security Group da EC2"
  value       = module.security_group.ec2_sg_id
}

output "rds_sg_id" {
  description = "ID do Security Group do RDS"
  value       = module.security_group.rds_sg_id
}
