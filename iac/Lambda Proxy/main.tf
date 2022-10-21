module main_deployment {
  source = "./main_deployment"

  app = var.app
  environment = var.environment
  http_port = var.http_port
  https_port = var.https_port
  internal = var.internal
  enable_large_file_support_via_presigned_url = var.enable_large_file_support_via_presigned_url
  compress_response = var.compress_response
  username = var.username

  tags = var.tags
}

module wire_up_services {
  source = "./wire_up_services"

  app = var.app
  environment = var.environment
  tags = var.tags
  network = module.main_deployment.network
  lb = module.main_deployment.lb
  oidc_config = module.main_deployment.oidc_config
}

module update_content_v1 {
  source = "./static_content_update"

  bucket = module.main_deployment.bucket
  content_dir = "one"
}

module update_content_v2 {
  source = "./static_content_update"

  bucket = module.main_deployment.bucket
  content_dir = "two"
}