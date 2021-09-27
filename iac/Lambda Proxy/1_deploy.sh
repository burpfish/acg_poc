#!/usr/bin/env sh

aws configure
terraform init
terraform apply -auto-approve
