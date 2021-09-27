resource "aws_lambda_function" "lambda" {
  function_name    = var.app
  role             = aws_iam_role.lambda_role.arn
  handler          = "s3-lambda-proxy.lambda_handler"
//  runtime          = "nodejs10.x"
  runtime          = "python3.7"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags             = var.tags

  vpc_config {
    subnet_ids         = var.network.subnets.*.id
    security_group_ids = [ aws_security_group.nsg_lambda.id ]
  }

  environment {
    variables = {
      BUCKET_NAME = var.bucket_id
      ENABLE_LARGE_FILE_SUPPORT_VIA_PRESIGNED_URL = var.enable_large_file_support_via_presigned_url
    }
  }

  # allow other ways of deploying code after initially provisioning
  lifecycle {
    ignore_changes = [ source_code_hash ]
  }
}

data "archive_file" "lambda_zip" {
  type                    = "zip"
//  source_content          = data.template_file.lambda_source.rendered
//  source_content_filename = "index.html"
  source_file             = "${path.module}/s3-lambda-proxy.py"
  output_path             = "lambda-${var.app}.zip"
}