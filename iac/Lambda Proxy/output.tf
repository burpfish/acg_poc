output alb_to_lambda_to_s3_proxy {
  value = "https://${module.lb.dns_name}/static/index.html"
}

output test_https {
  value = "https://www.burfordfc.com/static/"
}

output api_gateway_to_lambda_to_s3_proxy {
  value = "${module.api_gw.api_gw_stage_s3_lambda.invoke_url}/static/index.html"
}

output api_gateway_to_s3_proxy {
  value = "${module.api_gw.api_gw_stage_s3.invoke_url}/static/index.html"
}