resource "random_string" "random" {
  length           = 6
  special          = false
  upper            = false
}

module eks {
  source = "./eks"

  tags = var.tags
  environment = var.environment
  network = module.network
}

module "mock_oidc_auth_server" {
  source = "./mock_oidc_auth_server"

  tags = var.tags
  environment = var.environment
  username = var.username
  password = random_string.random.result
}

module "network" {
  source = "./network"

  tags = var.tags
  environment = var.environment
}

module "static_content" {
  source = "./static_content"

  tags = var.tags
  environment = var.environment
}

module "lb" {
  source = "./lb"

  network = module.network

  internal = var.internal
  http_port = var.http_port
  https_port = var.https_port

  tags = var.tags
  environment = var.environment
  app = var.app
  oidc_config = module.mock_oidc_auth_server
}

module "lambda" {
  source = "./lambda"

  bucket_id = module.static_content.bucket.id
  network = module.network

  tags = var.tags
  environment = var.environment
  app = var.app
  enable_large_file_support_via_presigned_url = var.enable_large_file_support_via_presigned_url
  compress_response = var.compress_response
}

module "connect_alb_to_lambda" {
  source = "./connect_alb_to_lambda"

  lambda = module.lambda
  lb = module.lb
}

module "ecr" {
  source = "./ecr"
}

module "iam" {
  source = "./iam"
}

## Disable API gw for now (focus on lb)
##module "connect_api_gw_to_lambda" {
##  source = "././connect_alb_to_lambda"
##
##  lambda = module.lambda
##  api_gw = module.api_gw
##}
#
#
#
##module "api_gw" {
##  source = "././api_gw"
##
##  network = module.network
##
##  tags = var.tags
##  environment = var.environment
##  app = var.app
##  lambda = module.lambda
##  static_content = module.static_content
##}