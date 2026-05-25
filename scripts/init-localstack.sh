#!/bin/bash
set -e

ENDPOINT="http://localhost:4566"
BUCKET="teleops-tf-state"
TABLE="tf-state-lock"
REGION="us-east-1"

echo ">>> Creando bucket S3 para estado de Terraform..."
awslocal s3api create-bucket --bucket $BUCKET --region $REGION

echo ">>> Habilitando versionado en el bucket..."
awslocal s3api put-bucket-versioning \
  --bucket $BUCKET \
  --versioning-configuration Status=Enabled

echo ">>> Creando tabla DynamoDB para bloqueo de estado..."
awslocal dynamodb create-table \
  --table-name $TABLE \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo ""
echo "✅ Backend listo:"
echo "   S3 bucket : $BUCKET"
echo "   DynamoDB  : $TABLE"
echo "   Endpoint  : $ENDPOINT"
