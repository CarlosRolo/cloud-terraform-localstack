#!/bin/bash
echo "=== Verificando infraestructura en LocalStack ==="
echo ""
echo ">>> VPCs:"
awslocal ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
echo ""
echo ">>> Subnets:"
awslocal ec2 describe-subnets --query 'Subnets[*].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
echo ""
echo ">>> EC2 Instances:"
awslocal ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,PrivateIpAddress,State.Name]' --output table
echo ""
echo ">>> S3 Buckets:"
awslocal s3 ls
echo ""
echo ">>> Security Groups:"
awslocal ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output table
echo ""
echo ">>> PostgreSQL (Docker):"
docker compose -f docker-compose.localstack.yml exec postgres psql -U teleops_admin -d teleopsdb -c "\l" 2>/dev/null && echo "✅ PostgreSQL conectado" || echo "⚠️  PostgreSQL no disponible"
echo ""
echo "=== Verificación completa ==="
