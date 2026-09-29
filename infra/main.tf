# =============================================================================
# Composição dos módulos — provider e backend estão em providers.tf
# =============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "aws-academy"
  }
}

# =============================================================================
# Módulo VPC
# =============================================================================
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

# =============================================================================
# Módulo Security Group
# — recebe vpc_id do módulo VPC
# =============================================================================
module "security_group" {
  source = "./modules/security-group"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id   # output do módulo vpc
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  tags              = local.common_tags
}

# =============================================================================
# Módulo RDS
# — recebe private_subnet_ids do módulo VPC
# — recebe rds_sg_id do módulo Security Group
# =============================================================================
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  instance_class     = var.rds_instance_class
  allocated_storage  = var.rds_allocated_storage
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  private_subnet_ids = module.vpc.private_subnet_ids  # output do módulo vpc
  security_group_id  = module.security_group.rds_sg_id # output do módulo security-group
  tags               = local.common_tags
}

# =============================================================================
# Módulo EC2
# — recebe public_subnet_ids do módulo VPC
# — recebe ec2_sg_id do módulo Security Group
# — recebe db_host/db_port/db_name do módulo RDS
# =============================================================================
module "ec2" {
  source = "./modules/ec2"

  project_name      = var.project_name
  instance_type     = var.ec2_instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]  # primeira subnet pública
  security_group_id = module.security_group.ec2_sg_id  # output do módulo security-group
  key_name          = var.key_name
  app_port          = var.app_port

  # Conexão com o RDS — outputs do módulo rds alimentam os inputs da EC2
  db_host     = module.rds.db_host
  db_port     = module.rds.db_port
  db_name     = module.rds.db_name
  db_user     = var.db_username
  db_password = var.db_password

  tags = local.common_tags
}
