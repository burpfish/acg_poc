#!/usr/bin/env sh

aws eks update-kubeconfig --region us-east-1 --name cluster
export KUBE_CONFIG_PATH=~/.kube/config

echo "Deploying nginx"
#kubectl delete ingress nginx
#kubectl delete service nginx-service
kubectl delete deployment nginx

terraform output -json > output.json

## TODO: Do not need access key and secret key, can use IAM
S3_BUCKET_NAME=$(jq -r '.main_deployment.value.bucket.bucket' output.json)
S3_ACCESS_KEY_ID=$(grep "^aws_access_key_id = " /home/dave/.aws/credentials | awk -F" = " '{print $2}')
S3_SECRET_KEY=$(grep "^aws_secret_access_key = " /home/dave/.aws/credentials | awk -F" = " '{print $2}')

cp ./k8s_deployment/nginx-s3-deployment_template.yaml ./k8s_deployment/nginx-s3-deployment.yaml
sed -i "s!<S3_BUCKET_NAME>!$S3_BUCKET_NAME!g" ./k8s_deployment/nginx-s3-deployment.yaml
sed -i "s!<S3_ACCESS_KEY_ID>!$S3_ACCESS_KEY_ID!g" ./k8s_deployment/nginx-s3-deployment.yaml
sed -i "s!<S3_SECRET_KEY>!$S3_SECRET_KEY!g" ./k8s_deployment/nginx-s3-deployment.yaml


kubectl create -f ./k8s_deployment/nginx-s3-deployment.yaml
#kubectl create -f ./k8s_deployment/nginx-deployment.yaml
kubectl create -f ./k8s_deployment/nginx-service.yaml
