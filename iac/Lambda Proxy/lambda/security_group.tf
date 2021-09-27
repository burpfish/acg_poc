# Lambda
resource "aws_security_group" "nsg_lambda" {
  name        = "${var.app}-${var.environment}-lambda"
  description = "Limit connections from internal resources while allowing ${var.app}-${var.environment}-lambda to connect to all external resources"
  vpc_id      = var.network.vpc.id
  tags        = var.tags
}

resource "aws_security_group_rule" "nsg_lambda_egress_rule" {
  security_group_id = aws_security_group.nsg_lambda.id
  description       = "Open egress"
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

//resource "aws_security_group_rule" "nsg_lambda_ingress_rule" {
//  security_group_id        = aws_security_group.nsg_lambda.id
//
//  description              = "Allow lb to call lambda"
//  type                     = "ingress"
//  from_port                = var.http_port
//  to_port                  = var.http_port
//  protocol                 = "tcp"
//  source_security_group_id = aws_security_group.nsg_lb.id
//}