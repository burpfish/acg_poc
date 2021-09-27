resource "aws_alb" "main" {
  name = "${var.app}-${var.environment}"

  # launch lbs in public or private subnets based on "internal" variable
  internal        = var.internal
  subnets         = var.network.subnets.*.id
  security_groups = [aws_security_group.nsg_lb.id]
  tags            = var.tags

  # enable access logs
//  access_logs {
//    enabled = true
//    bucket  = "${aws_s3_bucket.lb_access_logs.bucket}"
//  }

//  depends_on = [var.network.internet_gateway.id]
}

resource "aws_alb_target_group" "main" {
  name        = "${var.app}-${var.environment}"
  port        = var.http_port
  protocol    = "HTTP"
  vpc_id      = var.network.vpc.id
  target_type = "lambda"
  tags        = var.tags
}



//data "aws_elb_service_account" "main" {}
//
//# bucket for storing ALB access logs
//resource "aws_s3_bucket" "lb_access_logs" {
//  bucket        = "${var.app}-${var.environment}-lb-access-logs"
//  acl           = "private"
//  tags          = "${var.tags}"
//  force_destroy = true
//
//  lifecycle_rule {
//    id                                     = "cleanup"
//    enabled                                = true
//    abort_incomplete_multipart_upload_days = 1
//    prefix                                 = ""
//
//    expiration {
//      days = "${var.lb_access_logs_expiration_days}"
//    }
//  }
//
//  server_side_encryption_configuration {
//    rule {
//      apply_server_side_encryption_by_default {
//        sse_algorithm = "AES256"
//      }
//    }
//  }
//}
//
//# give load balancing service access to the bucket
//resource "aws_s3_bucket_policy" "lb_access_logs" {
//  bucket = "${aws_s3_bucket.lb_access_logs.id}"
//
//  policy = <<POLICY
//{
//  "Id": "Policy",
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "s3:PutObject"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "${aws_s3_bucket.lb_access_logs.arn}",
//        "${aws_s3_bucket.lb_access_logs.arn}/*"
//      ],
//      "Principal": {
//        "AWS": [ "${data.aws_elb_service_account.main.arn}" ]
//      }
//    }
//  ]
//}
//POLICY
//}