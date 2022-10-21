resource "aws_iam_role" "nginx_role" {
  name = "nginx_role"

  # TODO: Should lock down to just the bucket (being lazy)
  assume_role_policy  = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

#  inline_policy  = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Action   = "s3:*"
#        Effect   = "Allow"
#        Resource = "*"
#      }
#    ]
#  })
}