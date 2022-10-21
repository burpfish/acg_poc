output vpc {
  value = aws_vpc.main
}

output subnets {
  value = aws_subnet.main
}

output internet_gateway {
  value = aws_internet_gateway.gw
}
