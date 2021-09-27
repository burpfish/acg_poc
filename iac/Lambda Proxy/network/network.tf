data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  count      = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"

  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table_association" "subnet-associations"{
  count      = 2

  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3" // toso: hardcoded
}

resource "aws_vpc_endpoint_route_table_association" "ep-associations"{
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.route_table.id
}