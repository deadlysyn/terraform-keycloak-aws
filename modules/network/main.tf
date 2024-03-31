# Note: This module is meant as a starting point. In all liklihood
# you have your own infrastructure to provide as inputs. Minimally,
# consider the right cost/benefit tradeoffs for you.
#
# You could run singletons, but risk a single AZ going offline
# causing an outage. You could run instances in all AZs, but will
# incur more cost.
#
# As a starting point, we'll simply spread two across available
# AZs. This provides some HA, at minimal cost, and meets RDS'
# DBSubnetGroup requirements (at least two subnets in two AZs).

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_nat_gateway" "main" {
  count         = 2
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.nat[*].id, count.index)
  depends_on    = [aws_internet_gateway.main]
  tags          = var.tags
}

resource "aws_eip" "nat" {
  count      = 2
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]
  tags       = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  tags   = var.tags

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main[*].id, count.index)
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.public_cidr, 1, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  # map_public_ip_on_launch = true
  tags = var.tags
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.private_cidr, 1, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = var.tags
}
