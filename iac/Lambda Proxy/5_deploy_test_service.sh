#!/usr/bin/env sh

aws eks update-kubeconfig --region us-east-1 --name cluster
export KUBE_CONFIG_PATH=~/.kube/config

#kubectl delete ingress test-service
#kubectl delete service test-service
kubectl delete deployment test-service

echo "Deploying test service"
REGION=us-east-1
REPO_NAME=test_service
ACCOUNT_NUMBER=$(aws sts get-caller-identity --query 'Account' --output text)

TEST_SERVICE_IMAGE=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
sed "s!<IMAGE>!$TEST_SERVICE_IMAGE!g" ./k8s_deployment/test_service_template.yml > test_service.yml

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com

REPO_NAME=test_service
IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep hello-world | cut -d' ' -f2)
export TEST_SERVICE_IMAGE=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
docker tag $IMAGE_ID $TEST_SERVICE_IMAGE
docker push $TEST_SERVICE_IMAGE

## Create namespace, deploy service
echo ">> Update the image in test_service.yml to $TEST_SERVICE_IMAGE"
kubectl apply -f ./test_service.yml
# kubectl get all