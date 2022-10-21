#!/usr/bin/env sh

# We should not need to do this, fix it!
export KUBE_CONFIG_PATH=~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name cluster
terraform apply -auto-approve -target=module.main_deployment