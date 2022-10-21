#!/usr/bin/env sh
export KUBE_CONFIG_PATH=~/.kube/config
aws eks update-kubeconfig --region us-east-1 --name cluster
terraform apply -auto-approve -target=module.main_deployment


