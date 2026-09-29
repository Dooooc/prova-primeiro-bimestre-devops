# Prova Primeiro Bimestre — DevOps

**Nome:** Yuri Batista Sanches  
**RA:** 6325238

---

## Descrição do Projeto

API de Reservas em Node.js com Express e PostgreSQL, containerizada com Docker e infraestrutura provisionada na AWS com Terraform modularizado.

---

## Estrutura do Projeto

```
prova-primeiro-bimestre-devops/
├── app/                    # API de Reservas (Node.js + Express + Sequelize)
│   ├── src/
│   ├── package.json
│   ├── Dockerfile          # Multi-stage build com usuário não-root
│   └── .dockerignore
├── docker-compose.yml      # API + PostgreSQL (ambiente local)
├── .env.example
├── infra/                  # Terraform modularizado
│   ├── modules/
│   │   ├── vpc/            # VPC + subnets públicas/privadas em 2 AZs
│   │   ├── security-group/ # SGs com menor privilégio
│   │   ├── ec2/            # EC2 t2.micro + LabInstanceProfile
│   │   └── rds/            # RDS PostgreSQL db.t3.micro
│   ├── backend/            # S3 + DynamoDB para remote state
│   ├── main.tf             # Composição dos módulos
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf        # Provider AWS + backend S3
└── evidencias/
    ├── docker-build.txt
    ├── compose-ps.txt
    └── terraform-plan.txt
```

---

## Como Rodar Localmente

```bash
# Subir API + PostgreSQL
docker compose up -d --build

# Verificar containers
docker compose ps

# Verificar logs da API
docker logs prova-api
```

A API estará disponível em `http://localhost:3000`.

---

## Como Provisionar a Infraestrutura AWS

### Pré-requisitos
- Terraform >= 1.3.0
- AWS CLI
- Credenciais do AWS Academy

### 1. Configurar credenciais

```bash
source ./infra/aws-creds.sh
```

### 2. Criar o backend (S3 + DynamoDB)

```bash
# Criar bucket S3
aws s3api create-bucket --bucket prova-devops-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket prova-devops-terraform-state --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket prova-devops-terraform-state --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Criar DynamoDB para locking
cd infra/backend
terraform init && terraform apply
```

### 3. Subir a infraestrutura

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### Outputs após apply

| Output | Descrição |
|--------|-----------|
| `api_url` | URL de acesso à API na EC2 |
| `ec2_public_ip` | IP público da EC2 |
| `rds_endpoint` | Endpoint do RDS PostgreSQL |
| `vpc_id` | ID da VPC criada |

---

## Infraestrutura AWS

- **VPC** com subnets públicas e privadas em 2 AZs (us-east-1a, us-east-1b)
- **Security Groups** com menor privilégio: EC2 (22, 3000) e RDS (5432 só do SG da EC2)
- **EC2** t2.micro na subnet pública com LabInstanceProfile
- **RDS** PostgreSQL db.t3.micro nas subnets privadas (`publicly_accessible = false`, `storage_encrypted = true`)
- **Remote State** no S3 com versionamento + encriptação + DynamoDB para locking
