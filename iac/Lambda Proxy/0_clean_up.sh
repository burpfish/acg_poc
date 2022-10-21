#!/usr/bin/env sh

read -p 'Enter burfordfc private key: ' KEY
echo "$KEY" > ./main_deployment/lb/burfordfc.com_private_key.key

# Clean up (assumes the workspace has expired - i.e. we don't call tf destroy)
rm terraform.tfstate -f
aws configure
terraform init