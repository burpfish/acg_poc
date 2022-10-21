resource "aws_alb" "main" {
  name = "${var.app}-${var.environment}"

  # launch lbs in public or private subnets based on "internal" variable
  internal        = var.internal
  subnets         = var.network.subnets.*.id
  security_groups = [aws_security_group.nsg_lb.id]
  tags            = var.tags

  # enable access logs
  access_logs {
    enabled = true
    bucket  = "${aws_s3_bucket.lb_access_logs.bucket}"
    prefix  = "logs"
  }

//  depends_on = [var.network.internet_gateway.id]
}

resource "aws_alb_target_group" "main" {
  name        = "${var.app}-${var.environment}"
  port        = var.http_port
  protocol    = "HTTP"
  vpc_id      = var.network.vpc.id
  target_type = "lambda"
  tags        = var.tags

  health_check {
    matcher = "200,404"
    interval = 30
    timeout = 5
  }
}

data "aws_elb_service_account" "main" {}

# bucket for storing ALB access logs
resource "aws_s3_bucket" "lb_access_logs" {
  bucket_prefix = "lb-access-logs-"
  tags          = "${var.tags}"
  force_destroy = true
}

# give load balancing service access to the bucket (bad practice, overprovisioned)
resource "aws_s3_bucket_policy" "lb_access_logs" {
 bucket = "${aws_s3_bucket.lb_access_logs.id}"

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.lb_access_logs.arn}",
        "${aws_s3_bucket.lb_access_logs.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.main.arn}" ]
      }
    }
  ]
}
POLICY
}