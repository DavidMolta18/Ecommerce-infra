#!/bin/bash

# 🚀 Script para desplegar infraestructura dividida por módulos

set -e

STACK_PREFIX="ecommerce"
REGION="us-east-1"
PARAMS="file://params.json"

TEMPLATES=(
  "network.yml"
  "security.yml"
  "database.yml"
  "compute.yml"
  "monitoring.yml"
)

echo "📦 Desplegando stacks por módulo..."

for template in "${TEMPLATES[@]}"; do
  STACK_NAME="${STACK_PREFIX}-$(basename "$template" .yml)"
  echo "🔧 Deploying $STACK_NAME..."
  
  aws cloudformation deploy \
    --stack-name "$STACK_NAME" \
    --template-file "$template" \
    --parameter-overrides "$PARAMS" \
    --capabilities CAPABILITY_NAMED_IAM \
    --region "$REGION"

  echo "✅ $STACK_NAME desplegado"
  echo "----------------------------"
done

echo ""
echo "📤 Outputs de todos los stacks:"
for template in "${TEMPLATES[@]}"; do
  STACK_NAME="${STACK_PREFIX}-$(basename "$template" .yml)"
  echo "🔎 $STACK_NAME outputs:"
  aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table
  echo ""
done

echo "✅ ¡Despliegue completo y modularizado!"
