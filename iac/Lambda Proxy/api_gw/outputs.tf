output api_gw {
  value = aws_api_gateway_rest_api.proxy
}

output api_gw_stage_s3_lambda {
  value = aws_api_gateway_stage.proxy
}

output api_gw_stage_s3 {
  value = aws_api_gateway_stage.s3_proxy
}

output api_gateway_deployment_s3_lambda {
  value = aws_api_gateway_deployment.proxy
}

output api_gateway_deployment_s3 {
  value = aws_api_gateway_deployment.s3_proxy
}