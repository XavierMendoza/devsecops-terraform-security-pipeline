#!/bin/bash
set -e

echo "Running Terraform format check..."
terraform fmt -check

echo "Running Terraform validation..."
terraform validate

echo "Creating Terraform plan..."
terraform plan -out=tfplan.binary

echo "Converting plan to JSON..."
terraform show -json tfplan.binary > tfplan.json

echo "Running Checkov..."
checkov -d . --framework terraform

echo "Running OPA policy checks..."
opa eval --format pretty --data policies/terraform_security.rego --input tfplan.json "count(data.terraform.security.deny) == 0"

echo "All security checks passed."
