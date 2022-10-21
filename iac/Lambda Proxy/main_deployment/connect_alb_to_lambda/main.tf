resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = var.lb.alb_target_group.arn
  target_id        = var.lambda.lambda.arn
  depends_on       = [ aws_lambda_permission.allow_alb_to_invoke_lambda ]
}

resource "aws_lambda_permission" "allow_alb_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda.lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = var.lb.alb_target_group.arn
}
