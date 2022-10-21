locals {
  mime_types = tomap({
    "html" = "text/html"
    "txt" = "text/plain"
    "js" = "text/javascript"
    "js" = "application/octet-stream"
  })

  path = "${path.module}/${var.content_dir}/"
}

resource "aws_s3_bucket_object" "file_upload" {
  for_each = fileset(local.path, "**")

  bucket = var.bucket.id
  key    = each.value
  source = "${local.path}/${each.value}"
  etag   = filemd5("${local.path}/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[1], "application/octet-stream")
}

#Atm, nginx reads files from a different dir (fix w/ url rewrite)
resource "aws_s3_bucket_object" "file_upload_nginx" {
  for_each = fileset(local.path, "**")

  bucket = var.bucket.id
  key    = "nginx/${each.value}"
  source = "${local.path}/${each.value}"
  etag   = filemd5("${local.path}/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[1], "application/octet-stream")
}