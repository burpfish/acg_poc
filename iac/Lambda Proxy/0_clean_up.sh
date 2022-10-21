#!/usr/bin/env sh

touch ./main_deployment/lb/burfordfc.com_private_key.key
nano ./main_deployment/lb/burfordfc.com_private_key.key

# Clean up (assumes the workspace has expired - i.e. we don't call tf destroy)
rm terraform.tfstate -f
aws configure
terraform init