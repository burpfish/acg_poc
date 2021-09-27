resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "NOT FOUND"
        status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "static_http" {
  listener_arn = aws_alb_listener.http.arn
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


