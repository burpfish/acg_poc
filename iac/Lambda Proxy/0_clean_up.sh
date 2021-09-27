#!/usr/bin/env sh

# Clean up (assumes the workspace has expired - i.e. we don't call tf destroy)
rm terraform.tfstate -f