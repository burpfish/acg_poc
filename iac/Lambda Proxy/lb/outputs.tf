output alb_target_group {
  value = aws_alb_target_group.main
}

output "dns_name" {
  value = aws_alb.main.dns_name
}