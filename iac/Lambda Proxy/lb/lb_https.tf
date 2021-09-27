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

resource "aws_lb_listener_rule" "static_https" {
  listener_arn = aws_alb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}

resource "aws_acm_certificate" "cert" {
  certificate_body = file("${path.module}/burfordfc.com_ssl_certificate.cer")
  private_key      = file("${path.module}/burfordfc.com_private_key.key")
  certificate_chain = file("${path.module}/burfordfc.com_ssl_certificate_INTERMEDIATE.cer")
}