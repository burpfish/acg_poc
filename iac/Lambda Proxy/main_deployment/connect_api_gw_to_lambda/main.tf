resource "aws_lambda_permission" "allow_api_gw_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGW"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(var.api_gw.api_gateway_deployment_s3_lambda.execution_arn, var.api_gw.api_gw_stage_s3_lambda.stage_name, "")}*/*/*"
}