# Relatório — Prova Primeiro Bimestre DevOps

**Nome:** Yuri Batista Sanches  
**RA:** 6325238

---

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

Para conectar as peças do bimestre, fui seguindo o enunciado como guia de ordem de execução. Cada etapa dependia da anterior, o que tornou o caminho natural.

A ordem seguida foi:

**1. CRUD da API (Aula 01 — Git e Versionamento)**  
Primeiro desenvolvi a API de Reservas completa em Node.js com Express e Sequelize, com todas as rotas de CRUD funcionando. Em paralelo configurei o `.gitignore` para garantir que conteúdos sensíveis como `node_modules/`, `.env`, credenciais AWS e arquivos de estado do Terraform (`*.tfstate`) nunca subissem para o repositório.

**2. Dockerfile (Aula 03 — Docker e Containerização)**  
Com a API pronta, o próximo passo foi containerizá-la. O Dockerfile foi escrito com multi-stage build: o stage `deps` usa `node:20-alpine` e executa `npm ci --omit=dev` para instalar apenas dependências de produção, excluindo ferramentas de desenvolvimento como o nodemon. O stage `runner` cria um grupo e usuário sem privilégios (`appgroup`/`appuser`), copia os artefatos do stage anterior, aplica `chown` nos arquivos e define `USER appuser` — garantindo que o processo não rode como root.

**3. Docker Compose (Aula 04 — Orquestração local)**  
Com o container da API funcional, fui para o `docker-compose.yml` para orquestrar o ambiente local completo. Subi dois serviços: `postgres` (PostgreSQL 15-alpine com volume nomeado `postgres_data` para persistência e healthcheck via `pg_isready`) e `api` (build a partir do Dockerfile com `depends_on` usando `condition: service_healthy`, garantindo que a API só sobe após o banco estar pronto). Ambos conectados via rede bridge customizada `reservas-network`.

**4. Infraestrutura AWS com Terraform (Aulas 05, 06 e 07)**  
Com o ambiente local validado, parti para a infraestrutura na nuvem. Segui a seguinte ordem de módulos, pois cada um depende do anterior:

- **VPC** — base de toda a rede: criou a VPC (`10.0.0.0/16`), subnets públicas e privadas em duas AZs (`us-east-1a` e `us-east-1b`), Internet Gateway e route tables separadas para cada tier.
- **Security Group** — com a VPC criada, foi possível definir os SGs usando o `vpc_id` como input. O SG da EC2 libera as portas 22 e 3000; o SG do RDS libera a 5432 apenas a partir do SG da EC2, aplicando o princípio de menor privilégio.
- **EC2** — com subnet pública e SG da EC2 disponíveis como outputs, foi possível criar a instância `t2.micro` com `LabInstanceProfile` (role pré-existente do Academy, sem criar IAM roles) e user data que instala Docker e sobe a API automaticamente.
- **RDS** — com as subnets privadas e SG do RDS disponíveis, o PostgreSQL `db.t3.micro` foi provisionado com `publicly_accessible = false`, `storage_encrypted = true` e DB Subnet Group nas subnets privadas.
- **Remote State** — o bucket S3 foi criado via AWS CLI (o SCP do Academy bloqueia `s3:GetBucketObjectLockConfiguration` via Terraform) com versionamento e encriptação AES-256 habilitados. A tabela DynamoDB para locking foi criada via Terraform. O backend foi configurado em `providers.tf` apontando para os dois recursos.

---

## Questão 2 — O Processo com IA como Copiloto

A ferramenta utilizada foi o **Kiro**, um ambiente de desenvolvimento com IA integrada baseado em VS Code. A interação foi feita no modo Vibe (conversacional), sem uso do fluxo Spec.

**Como foi usada**  
A IA foi utilizada como copiloto durante todo o desenvolvimento: gerava o código inicial a partir de descrições do que era necessário, e eu revisava, testava e pedia ajustes. Os prompts principais foram diretos e incrementais, por exemplo: "cria o Dockerfile multi-stage com usuário não-root", "adiciona rede bridge customizada, healthcheck e depends_on com condição no docker-compose", "cria o módulo VPC com subnets públicas e privadas em 2 AZs". Cada entrega era conferida antes de seguir para o próximo passo.

**O que a IA gerou bem**  
A IA foi precisa na estrutura dos módulos Terraform, aplicando corretamente a composição entre outputs e inputs (ex: `module.vpc.vpc_id` alimentando o `module.security_group`, `module.rds.db_host` alimentando o `module.ec2`). O Dockerfile multi-stage com usuário não-root e o docker-compose com healthcheck e `condition: service_healthy` também foram gerados corretamente de primeira, sem necessidade de correção.

**O que precisou corrigir**  
Os principais problemas apareceram na execução contra o AWS Academy:
- A versão do PostgreSQL `15.7` não estava disponível na região — corrigido para `15` sem patch version.
- O volume da EC2 foi definido como 20GB, mas a AMI do Amazon Linux 2023 exige mínimo de 30GB — corrigido após o erro do `terraform apply`.
- O SCP do AWS Academy bloqueia `s3:GetBucketObjectLockConfiguration`, impedindo que o Terraform criasse o bucket S3 normalmente. Toda vez que o `terraform apply` era executado, retornava `AccessDenied` com `api error AccessDenied: User: arn:aws:sts::...:assumed-role/voclabs/... is not authorized to perform: s3:GetBucketObjectLockConfiguration ... with an explicit deny in a service control policy`. Foram tentadas várias abordagens via código (`object_lock_enabled = false`, `skip_requesting_account_id`, renomear o bucket, limpar o state local) sem sucesso. A solução final foi criar o bucket via AWS CLI com versionamento e encriptação AES-256, e gerenciar apenas o DynamoDB pelo Terraform.
- O arquivo `docker-compose.yml` inicial não tinha o serviço da API — foi necessário pedir para adicionar explicitamente.

**Comparação com fazer manualmente**  
A IA economizou tempo significativo na escrita dos módulos Terraform, que envolve muita sintaxe repetitiva e referências entre recursos. Gerar os quatro módulos com variables, outputs e composição entre eles manualmente levaria muito mais tempo. Por outro lado, a IA não tem como saber as restrições específicas do AWS Academy (SCP, versões disponíveis de AMI e RDS), então esses ajustes precisaram ser feitos na hora com base nos erros retornados pelo `terraform apply`. No geral, a IA acelerou a parte de escrita e estruturação, enquanto o diagnóstico e resolução de erros de ambiente dependeram da interação em tempo real.

---

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

**Arquitetura provisionada**

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
VPC (10.0.0.0/16)
├── Subnet Pública us-east-1a (10.0.1.0/24)
│       └── EC2 t2.micro (API Node.js — porta 3000)
│               └── SG-EC2: ingress 22, 3000 / egress all
├── Subnet Pública us-east-1b (10.0.2.0/24)
├── Subnet Privada us-east-1a (10.0.3.0/24)
│       └── RDS PostgreSQL db.t3.micro
│               └── SG-RDS: ingress 5432 apenas do SG-EC2
└── Subnet Privada us-east-1b (10.0.4.0/24)
        └── (DB Subnet Group exige mínimo 2 AZs)
```

Remote State: S3 (`prova-devops-terraform-state`) + DynamoDB (`prova-devops-terraform-lock`)

**Por que o RDS fica na subnet privada e a EC2 na pública?**

Coloquei a EC2 na subnet pública porque ela precisa ser acessível pela internet — é ela que recebe as requisições da API na porta 3000 e também permite acesso SSH para administração. O RDS eu coloquei na subnet privada porque o banco de dados não precisa ser acessado diretamente de fora, só a API precisa falar com ele. Com `publicly_accessible = false`, não existe nenhuma rota vindo da internet até o banco, o que diminui muito o risco de acesso indevido. A comunicação entre a EC2 e o RDS acontece dentro da própria VPC pela porta 5432, e ainda tem o Security Group do RDS configurado para aceitar tráfego somente do SG da EC2 — então mesmo dentro da VPC, só a EC2 consegue se conectar ao banco.

**LabRole e LabInstanceProfile**

O AWS Academy não deixa criar IAM users, groups ou roles. Quando precisei dar permissões para a EC2 acessar serviços AWS, usei o `LabInstanceProfile` que já vem pré-configurado na conta do Academy com a `LabRole` associada. No Terraform ficou assim:

```hcl
iam_instance_profile = "LabInstanceProfile"
```

Dessa forma eu apenas referenciei o profile que já existia, sem precisar criar nada de IAM e sem quebrar as regras do laboratório.

**Ajustes exigidos pelo AWS Academy Learner Lab**

- **Credenciais temporárias**: no Academy as credenciais expiram quando a sessão do lab termina, então toda vez que eu abria o lab precisava pegar as novas credenciais em "AWS Details" e setar as variáveis de ambiente de novo. Para não ficar digitando três variáveis toda hora, criei o `aws-creds.sh` (Linux) e o `aws-creds.ps1` (Windows) só com os campos para preencher. Os dois estão no `.gitignore` para não vazar nada.

- **Restrições de IAM**: qualquer tentativa de criar recursos IAM dava erro de permissão imediatamente. Tudo que precisava de permissão foi resolvido com o `LabRole`/`LabInstanceProfile` já existentes.

- **Restrições de SCP**: o Academy bloqueia algumas operações via Service Control Policy mesmo para a `LabRole`. O que me travou mais foi o bloqueio do `s3:GetBucketObjectLockConfiguration` — o Terraform chamava isso automaticamente ao tentar criar ou ler o bucket S3, e retornava `AccessDenied`. Tentei várias formas de contornar pelo código mas nenhuma funcionou. No final criei o bucket direto pelo AWS CLI configurando versionamento e encriptação manualmente, e deixei só o DynamoDB para o Terraform gerenciar.

- **Região**: usei `us-east-1` que é a padrão do Academy e tem todos os serviços disponíveis.

---

## Questão 4 — Validação e Responsabilidade

**Checklist antes do terraform apply**

Antes de rodar qualquer `terraform apply` em código gerado pela IA, eu sempre lia o código completo primeiro. Meu checklist foi:

1. Ler tudo que foi gerado — variáveis, recursos e outputs — e ver se batia com o que eu tinha pedido
2. Rodar `terraform validate` para checar se a sintaxe e as referências entre recursos estavam corretas
3. Confirmar que não estava sendo criado nenhum recurso IAM, já que o Academy não permite
4. Ver se o `LabInstanceProfile` estava só sendo referenciado, não criado
5. Checar se o RDS estava com `publicly_accessible = false` e `storage_encrypted = true`
6. Verificar se o Security Group do RDS só aceitava conexão do SG da EC2, sem deixar nenhum CIDR aberto
7. Rodar `terraform plan` antes do `apply` para ver exatamente o que ia ser criado ou mudado
8. Ler o output do plan e confirmar se o número de recursos fazia sentido com o que eu esperava

**Como validei que a infraestrutura estava correta**

Depois do `apply`, usei os outputs do Terraform pra confirmar: IP da EC2, endpoint do RDS, IDs dos recursos. Também olhei o `terraform show` pra ver se os atributos importantes estavam certos — `publicly_accessible = false` no RDS, `iam_instance_profile = "LabInstanceProfile"` na EC2, as subnets privadas no DB Subnet Group. Quando a API subiu e conectou no banco, isso já foi uma validação de que o fluxo todo estava funcionando.

**O que aconteceria sem revisar**

Se eu tivesse aceitado tudo sem olhar, vários problemas teriam passado:

- A versão `15.7` do PostgreSQL teria dado erro no `apply` e eu não saberia por quê
- O volume de 20GB da EC2 teria falhado porque a AMI exige pelo menos 30GB
- O `docker-compose.yml` sem o serviço da API teria subido só o banco e eu ficaria perdido tentando entender por que a API não aparecia
- O bucket S3 teria travado em loop de `AccessDenied` sem saída

E o pior: sem entender o código, eu não conseguiria nem diagnosticar esses erros quando aparecessem.

**Como a evolução Git → Docker → Terraform → Modules me preparou**

Cada tecnologia do bimestre me ensinou a entender o que estava acontecendo antes de executar qualquer coisa:

- **Git** me acostumou a revisar mudanças antes de commitar — o mesmo raciocínio de "o que está sendo alterado?" se aplica ao `terraform plan`
- **Docker** me ensinou a entender o que cada instrução faz — sem isso eu não saberia avaliar se o multi-stage estava certo ou se o usuário não-root estava sendo aplicado de verdade
- **Terraform** me fez entender que infraestrutura como código tem consequências reais — um RDS mal configurado expõe dados ou gera custo
- **Módulos** me ensinaram a pensar em dependências — entender que o output de um módulo alimenta o input de outro me ajudou a verificar se a composição gerada pela IA fazia sentido

No final, usar IA com responsabilidade pra mim foi isso: ter o conhecimento suficiente pra saber o que revisar, o que questionar e o que testar antes de rodar.
