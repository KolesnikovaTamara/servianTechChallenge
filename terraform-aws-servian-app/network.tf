resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  cidr_block              = lookup(var.public_subnets[count.index], "cidr")
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone       = lookup(var.public_subnets[count.index], "az")

  tags = {
    Name = lookup(var.public_subnets[count.index], "name")
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  cidr_block        = lookup(var.private_subnets[count.index], "cidr")
  vpc_id            = aws_vpc.main.id
  availability_zone = lookup(var.private_subnets[count.index], "az")

  tags = {
    Name = lookup(var.private_subnets[count.index], "name")
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets)

  vpc = true
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnets)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)

  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private" {
  count                  = length(var.private_subnets)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
