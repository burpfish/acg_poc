#!/usr/bin/env sh
export KUBE_CONFIG_PATH=~/.kube/config

terraform apply -auto-approve -target=module.update_content_v1