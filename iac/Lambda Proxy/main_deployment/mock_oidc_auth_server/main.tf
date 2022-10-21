locals {
  config_url = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.pool.id}/.well-known/openid-configuration"
  decoded_openid_config = jsondecode(data.http.openid_config.body)

  authorization_endpoint = local.decoded_openid_config.authorization_endpoint
  issuer = local.decoded_openid_config.issuer
  jwks_uri = local.decoded_openid_config.jwks_uri
  token_endpoint = local.decoded_openid_config.token_endpoint
  userinfo_endpoint = local.decoded_openid_config.userinfo_endpoint
}


resource "aws_cognito_user_pool" "pool" {
  name = "oidc"

  # Super bad practice = simpler testing!
  password_policy {
    minimum_length = 6
    require_lowercase = false
    require_numbers = false
    require_symbols = false
    require_uppercase = false
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "test-auth-${random_string.random.id}"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "random_string" "random" {
  length           = 6
  special          = false
  upper            = false
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "lb-test-app"
  generate_secret                      = true
  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = ["https://api.burfordfc.com/oauth2/idpresponse"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user" "example" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = var.username
  password     = var.password
}

data "http" "openid_config" {
  url = local.config_url
}

data "aws_region" "current" {}

