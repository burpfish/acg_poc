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
}

module "lambda" {
  source = "./lambda"

  bucket_id = module.static_content.bucket.id
  network = module.network

  tags = var.tags
  environment = var.environment
  app = var.app
  enable_large_file_support_via_presigned_url = var.enable_large_file_support_via_presigned_url
}

module "connect_to_lambda" {
  source = "./connect_to_lambda"

  lambda = module.lambda
  lb = module.lb
  api_gw = module.api_gw
}

module "api_gw" {
  source = "./api_gw"

  network = module.network

  tags = var.tags
  environment = var.environment
  app = var.app
  lambda = module.lambda
  static_content = module.static_content
}