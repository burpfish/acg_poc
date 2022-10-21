# LB
resource "aws_security_group" "nsg_lb" {
  name        = "${var.app}-${var.environment}-lb"
  description = "Allow connections from external resources while limiting connections from ${var.app}-${var.environment}-lb to internal resources"
  vpc_id      = var.network.vpc.id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_lb_http" {
  type = "ingress"
  description = "http ingress"
  from_port = 80
  to_port = 81
  protocol = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.nsg_lb.id
}

resource "aws_security_group_rule" "ingress_lb_https" {
  type = "ingress"
  description = "http ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.nsg_lb.id
}

// Need to allow outbound to the idp (cognito); we're using brunt force
resource "aws_security_group_rule" "egress_idp" {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}

// Do we need this??
resource "aws_security_group_rule" "egress_idp_2" {
  type = "egress"
  from_port = 80
  to_port = 81
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}

//resource "aws_security_group_rule" "nsg_lb_egress_rule" {
//  security_group_id        = aws_security_group.nsg_lb.id
//  description              = "Only allow SG ${var.app}-${var.environment}-lb to connect to ${var.app}-${var.environment}-lambda on port ${var.lb_port}"
//  type                     = "egress"
//  from_port                = var.lb_port
//  to_port                  = var.lb_port
//  protocol                 = "tcp"
//  source_security_group_id = aws_security_group.nsg_lambda.id
//}