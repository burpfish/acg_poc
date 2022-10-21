# NLB to sit infront of the ALB provisioned by EKS - to give static ip
resource "aws_lb" "nlb_fronting_k8s_alb" {
  name               = "nlb-fronting-k8s-alb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.network.subnets.*.id

  tags = var.tags
}

# Target group - k8s ingress alb
resource "aws_lb_target_group" "nlb_fronting_k8s" {
  name     = "nlb-fronting-k8s-alb"

  port     = 80
  protocol = "TCP"
  target_type = "alb"
  vpc_id   = var.network.vpc.id
}

resource "aws_lb_target_group_attachment" "nlb_fronting_k8s_tg_attachment" {
  target_group_arn = aws_lb_target_group.nlb_fronting_k8s.arn
  target_id        = data.aws_lb.test_app_k8s_lb.id
  port             = 80
}

# Listener - from nlb to k8s alb
resource "aws_lb_listener" "nlb_fronting_k8s_alb" {
  load_balancer_arn = aws_lb.nlb_fronting_k8s_alb.id
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.nlb_fronting_k8s.arn
    type             = "forward"
  }
}

# Wire the NLB into the primary ALB
data "aws_network_interface" "lb_ips" {
  for_each = toset(var.network.subnets.*.id)

  filter {
    name   = "description"
    values = ["ELB ${aws_lb.nlb_fronting_k8s_alb.arn_suffix}"]
  }

  filter {
    name   = "subnet-id"
    values = [each.value]
  }
}

resource "aws_lb_target_group" "primary_alb_to_nlb_fronting_k8s" {
  name     = "pri-alb-to-lb-fronting-k8s-alb1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.network.vpc.id
  target_type = "ip"
}

# We have this linked up to port 81. and then for http and https, hence the repetition
# todo: looks like we may be able to re-use these after all ...
resource "aws_lb_target_group_attachment" "primary_alb_to_nlb_fronting_k8s_tg_attachment1" {
  for_each = data.aws_network_interface.lb_ips

  target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
  port             = 80
  target_id        = each.value.private_ip
}

resource "aws_lb_listener" "primary_alb_to_nlb_fronting_k8s" {
  load_balancer_arn = var.lb.primary_alb.id
  port              = "81"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "nginx_http" {
  listener_arn = data.aws_lb_listener.test_app_http.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
  }

  condition {
    path_pattern {
      values = ["/nginx/*"]
    }
  }
}

#resource "aws_lb_listener_rule" "nginx_https" {
#  listener_arn = data.aws_lb_listener.test_app_https.arn
#  priority     = 300
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
#  }
#
#  condition {
#    path_pattern {
#      values = ["/nginx/*"]
#    }
#  }
#}

resource "aws_lb_listener_rule" "nginx_protected" {
  listener_arn = data.aws_lb_listener.test_app_https.arn
  priority     = 350

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
    target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
  }

  condition {
    path_pattern {
      values = ["/nginx/*"]
    }
  }
}

resource "aws_lb_listener_rule" "test_service_http" {
  listener_arn = data.aws_lb_listener.test_app_http.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
  }

  condition {
    path_pattern {
      values = ["/test-service/*"]
    }
  }
}

#resource "aws_lb_listener_rule" "test_service_https" {
#  listener_arn = data.aws_lb_listener.test_app_https.arn
#  priority     = 400
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
#  }
#
#  condition {
#    path_pattern {
#      values = ["/test-service/*"]
#    }
#  }
#}

resource "aws_lb_listener_rule" "test_service_protected" {
  listener_arn = data.aws_lb_listener.test_app_https.arn
  priority     = 450

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
    target_group_arn = aws_lb_target_group.primary_alb_to_nlb_fronting_k8s.arn
  }

  condition {
    path_pattern {
      values = ["/test-service/*"]
    }
  }
}