# CLOUD-02: Infrastructure as Code with Terraform + LocalStack

![Terraform](https://img.shields.io/badge/Terraform-1.15-7B42BC?logo=terraform)
![LocalStack](https://img.shields.io/badge/LocalStack-3.4-FF6600?logo=amazon-aws)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14-336791?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-green)

AWS-compatible infrastructure defined entirely as code using **Terraform** and **LocalStack** — no AWS account required. Provisions a production-grade network topology with VPC, EC2, S3, and PostgreSQL, including remote state management with S3 backend and DynamoDB locking.

## Architecture

```
+---------------------------------------------------------+
|           LocalStack (Docker) - AWS API                 |
|               endpoint: localhost:4566                  |
|                                                         |
|  +---------------- VPC 10.0.0.0/16 -----------------+   |
|  |                                                  |   |
|  |  +-- Public Subnet 10.0.1.0/24 ---------------+  |   |
|  |  |  EC2 t3.micro                              |  |   |
|  |  |  Security Group (22/80/443)                |  |   |
|  |  |  Internet Gateway                          |  |   |
|  |  +--------------------------------------------+  |   |
|  |                                                  |   |
|  |  +-- Private Subnet 10.0.2.0/24 --------------+  |   |
|  |  |  PostgreSQL 14 (Docker)                    |  |   |
|  |  |  Security Group (5432 VPC only)            |  |   |
|  |  +--------------------------------------------+  |   |
|  +---------------------------------------------------+  |
|                                                         |
|  S3: teleops-data-local   (application data)            |
|  S3: teleops-tf-state     (Terraform remote state)      |
|  DynamoDB: tf-state-lock  (state locking)               |
+---------------------------------------------------------+
```

## Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | 1.15.4 | Infrastructure as Code |
| LocalStack | 3.4.0 | AWS API simulation (Docker) |
| AWS Provider | 5.100.0 | Terraform AWS resources |
| PostgreSQL | 14-alpine | Relational database (Docker) |
| awscli-local | 0.22.2 | LocalStack CLI wrapper |

## Resources Provisioned

| Resource | Name | Details |
|----------|------|---------|
| VPC | teleops-vpc | 10.0.0.0/16, DNS enabled |
| Subnet public | teleops-public-subnet | 10.0.1.0/24 |
| Subnet private | teleops-private-subnet | 10.0.2.0/24 |
| Internet Gateway | teleops-igw | Attached to VPC |
| Route Table | teleops-public-rt | 0.0.0.0/0 via IGW |
| EC2 Instance | teleops-ec2 | t3.micro, Amazon Linux 2 |
| Security Group | teleops-ec2-sg | 22/80/443 ingress |
| Security Group | teleops-rds-sg | 5432 from VPC only |
| S3 Bucket | teleops-data-local | Private, versioned |
| S3 Bucket | teleops-tf-state | Remote state backend |
| DynamoDB Table | tf-state-lock | State locking |
| PostgreSQL | teleopsdb | Port 5432, private subnet |

## Project Structure

```
cloud-terraform-localstack/
├── main.tf                          # Root module - calls all modules
├── variables.tf                     # Global variables
├── outputs.tf                       # Global outputs
├── provider.tf                      # AWS provider pointed to LocalStack
├── backend.tf                       # Remote state: S3 + DynamoDB
├── docker-compose.localstack.yml    # LocalStack + PostgreSQL
├── Makefile                         # Convenience commands
├── modules/
│   ├── vpc/                         # VPC, subnets, IGW, route tables
│   ├── ec2/                         # EC2 instance + security group
│   ├── s3/                          # S3 bucket + access policies
│   └── rds/                         # RDS security group + PostgreSQL
└── scripts/
    ├── init-localstack.sh           # Creates S3 backend + DynamoDB table
    └── verify.sh                    # Verifies all provisioned resources
```

## Quick Start

### Prerequisites

- Docker + Docker Compose
- Terraform >= 1.5.0
- Python 3 + pip

### Install dependencies

```bash
pip3 install localstack awscli-local awscli --break-system-packages
sudo apt install terraform -y
```

### Run

```bash
# 1. Start LocalStack + PostgreSQL
docker compose -f docker-compose.localstack.yml up -d

# 2. Initialize backend (S3 bucket + DynamoDB table)
bash scripts/init-localstack.sh

# 3. Initialize Terraform
terraform init

# 4. Preview infrastructure
terraform plan

# 5. Apply
terraform apply -auto-approve

# 6. Verify all resources
bash scripts/verify.sh
```

### Makefile commands

```bash
make init     # init-localstack + terraform init
make plan     # terraform plan
make apply    # terraform apply -auto-approve
make verify   # run verify.sh
make destroy  # terraform destroy -auto-approve
```

## Key Concepts Demonstrated

**Infrastructure as Code** — every resource is declarative HCL, version-controlled and reproducible. No manual clicks in a console.

**Modular Terraform** — each service (VPC, EC2, S3, RDS) is an independent reusable module with its own variables and outputs. Adding a new environment is a single tfvars file.

**Remote State** — Terraform state stored in S3 with DynamoDB locking prevents concurrent modifications and enables team collaboration.

**Least-privilege Security** — RDS Security Group restricts PostgreSQL access to VPC CIDR only (10.0.0.0/16). SSH restricted to private ranges. S3 bucket blocks all public access.

**LocalStack** — full AWS API simulation locally at zero cost. The same HCL deploys to real AWS by removing the custom endpoints block from provider.tf — zero code changes required.

## Verified Outputs

```
ec2_instance_id   = "i-5de321bd62e2d7057"
ec2_private_ip    = "10.0.1.4"
public_subnet_id  = "subnet-dcd75b62"
private_subnet_id = "subnet-b5979bbb"
s3_bucket_id      = "teleops-data-local"
rds_endpoint      = "localhost:5432"
rds_db_name       = "teleopsdb"
vpc_id            = "vpc-adade73e"
```
---
 
## Autor
 
**Carlos David Rodriguez Lopez**  
Telematic Engineer — ESPOCH  
Riobamba, Chimborazo, Ecuador  
Manta, Manabí, Ecuador  
GitHub: [github.com/CarlosRolo](https://github.com/CarlosRolo)  
LinkedIn: [linkedin.com/in/carlosdrodriguezl](https://linkedin.com/in/carlosdrodriguezl)
 
---

## License

MIT License — see [LICENSE](LICENSE)
