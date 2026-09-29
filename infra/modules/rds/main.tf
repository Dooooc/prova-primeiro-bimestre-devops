# =============================================================================
# DB Subnet Group — subnets privadas em 2 AZs
# =============================================================================
resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Subnet group para o RDS PostgreSQL nas subnets privadas"
  subnet_ids  = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

# =============================================================================
# RDS PostgreSQL
# =============================================================================
resource "aws_db_instance" "this" {
  identifier        = "${var.project_name}-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  # Segurança
  publicly_accessible    = false
  storage_encrypted      = true
  deletion_protection    = false
  skip_final_snapshot    = true

  # Rede
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  # Manutenção
  backup_retention_period = 7
  multi_az                = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-postgres"
  })
}
