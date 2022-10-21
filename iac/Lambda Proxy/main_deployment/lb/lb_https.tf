resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port              = var.https_port
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate.cert.arn

  default_action {
    type = "redirect"

    redirect {
      status_code = "HTTP_301"
      path        = "/static/index.html"
    }
  }
}

#resource "aws_lb_listener_rule" "s3_https" {
#  listener_arn = aws_alb_listener.https.arn
#  priority     = 101
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_alb_target_group.main.arn
#  }
#
#  condition {
#    path_pattern {
#      values = ["/s3/*"]
#    }
#  }
#}

resource "aws_lb_listener_rule" "oidc" {
  listener_arn = aws_alb_listener.https.arn
  priority     = 200

  action {
    type = "authenticate-oidc"

    authenticate_oidc {
      authorization_endpoint = var.oidc_config.authorization_endpoint
      client_id              = var.oidc_config.client_id
      client_secret          = var.oidc_config.client_secret
      issuer                 = var.oidc_config.issuer
      token_endpoint         = var.oidc_config.token_endpoint
      user_info_endpoint     = var.oidc_config.userinfo_endpoint
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/s3/*"]
    }
  }
}


resource "aws_acm_certificate" "cert" {
  certificate_body = file("${path.module}/burfordfc.com_ssl_certificate.cer")
  private_key      = file("${path.module}/burfordfc.com_private_key.key")
  certificate_chain = file("${path.module}/burfordfc.com_ssl_certificate_INTERMEDIATE.cer")
}