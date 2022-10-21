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

#Atm, nginx reads files from a different dir (fix w/ url rewrite)
resource "aws_s3_bucket_object" "file_upload_nginx" {
  for_each = fileset("${path.module}/upload/", "**")

  bucket = aws_s3_bucket.static_content.id
  key    = "nginx/${each.value}"
  source = "${path.module}/upload/${each.value}"
  etag   = filemd5("${path.module}/upload/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[1], "application/octet-stream")
}

// TODO: Use this to restrict bucket role (or vpc_link to squirt through vpc endpoint)
//{
//"Version": "2012-10-17",
//"Statement": [
//{
//"Sid": "1",
//"Effect": "Deny",
//"Principal": "*",
//"Condition": {
//"ArnNotLike": {
//"aws:PrincipalArn": [
//"arn:aws:iam::876757926184:role/apigw_s3"
//]
//}
//},
//"Action": "s3:*",
//"Resource": [
//"arn:aws:s3:::static-content-20210927182618621100000001",
//"arn:aws:s3:::static-content-20210927182618621100000001/*"
//]
//}
//]
//}