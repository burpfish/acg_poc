data "aws_lb" "test_app_k8s_lb" {
  tags = {
    "app" = "test_app"
  }
}

data "aws_lb_listener" "test_app_http" {
  load_balancer_arn = var.lb.primary_alb.id
  port              = 80
}

data "aws_lb_listener" "test_app_https" {
  load_balancer_arn = var.lb.primary_alb.id
  port              = 443
}