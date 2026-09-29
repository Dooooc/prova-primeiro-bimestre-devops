# =============================================================================
# Data source: AMI Amazon Linux 2023 mais recente
# =============================================================================
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================================
# EC2 Instance
# =============================================================================
resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  # LabInstanceProfile — permite acesso a serviços AWS sem criar IAM roles
  iam_instance_profile = "LabInstanceProfile"

  # Script de inicialização: instala Docker e sobe a API
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_host     = var.db_host
    db_port     = var.db_port
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    app_port    = var.app_port
  }))

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2"
  })
}
