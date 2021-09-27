locals {
  mime_types = tomap({
    "html" = "text/html"
    "txt" = "text/plain"
    "js" = "text/javascript"
    "js" = "application/octet-stream"
  })
}

resource "aws_s3_bucket" "static_content" {
  bucket_prefix  = "static-content-"
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_bucket_object" "file_upload" {
  for_each = fileset("${path.module}/upload/", "**")

  bucket = aws_s3_bucket.static_content.id
  key    = each.value
  source = "${path.module}/upload/${each.value}"
  etag   = filemd5("${path.module}/upload/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[1], "application/octet-stream")
}