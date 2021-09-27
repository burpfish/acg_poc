resource "aws_api_gateway_rest_api" "proxy" {
  name = "proxy_lambda_s3"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  parent_id   = aws_api_gateway_rest_api.proxy.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.proxy.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.proxy.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.proxy.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda.lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.proxy.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.proxy.body))
  }

  depends_on = [
    aws_api_gateway_integration.integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "proxy" {
  deployment_id = aws_api_gateway_deployment.proxy.id
  rest_api_id   = aws_api_gateway_rest_api.proxy.id
  stage_name    = "v1"
}