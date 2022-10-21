output "authorization_endpoint" {
  value = local.authorization_endpoint
}

output "issuer" {
  value = local.issuer
}

output "jwks_uri" {
  value = local.jwks_uri
}

output "token_endpoint" {
  value = local.token_endpoint
}

output "userinfo_endpoint" {
  value = local.userinfo_endpoint
}

output "config_url" {
  value = local.config_url
}

output "decoded_openid_config" {
  value = local.decoded_openid_config
}

output "client_id" {
  value = aws_cognito_user_pool_client.userpool_client.id
}

output "client_secret" {
  value = aws_cognito_user_pool_client.userpool_client.client_secret
}