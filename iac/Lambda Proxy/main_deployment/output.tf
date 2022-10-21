output bucket {
  value = module.static_content.bucket
}

output vpc_id {
  value = module.network.vpc.id
}

output username {
  value = var.username
}

output password {
  value = random_string.random.result
}

output eks {
  value = module.eks
}

output network {
  value = module.network
}

output lb {
  value = module.lb
}

output oidc_config {
  value = module.mock_oidc_auth_server
}

output iam {
  value = module.iam
}