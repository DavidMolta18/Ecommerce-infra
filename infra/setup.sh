#!/bin/bash

# Script simple para desplegar infraestructura E-commerce
set -e

STACK_NAME="ecommerce-infra"
TEMPLATE_FILE="infrall.yml"
REGION="us-east-1"

echo "🚀 Desplegando infraestructura E-commerce..."

# Validar template
echo "Validando template..."
aws cloudformation validate-template --template-body file://$TEMPLATE_FILE --region $REGION

# Crear stack
echo "Creando stack..."
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --capabilities CAPABILITY_IAM \
    --region $REGION

# Esperar que se complete
echo "Esperando que se complete el despliegue..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION

# Obtener outputs
echo ""
echo "==================== RESULTADO ===================="
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table

echo ""
echo "✅ ¡Despliegue completado!"