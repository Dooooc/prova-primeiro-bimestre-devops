#!/bin/bash
set -e

# Atualiza pacotes e instala Docker
yum update -y
yum install -y docker git

# Inicia e habilita Docker
systemctl start docker
systemctl enable docker

# Clona o repositório da aplicação
cd /home/ec2-user
git clone https://github.com/placeholder/reservas-api.git app || true

# Cria o .env com as variáveis do banco (RDS)
cat > /home/ec2-user/app/app/.env <<EOF
PORT=${app_port}
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF

# Build e execução do container da API
cd /home/ec2-user/app
docker build -t reservas-api ./app
docker run -d \
  --name reservas-api \
  --restart unless-stopped \
  -p ${app_port}:${app_port} \
  --env-file ./app/.env \
  reservas-api
