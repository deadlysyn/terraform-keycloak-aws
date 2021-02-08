output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  value = aws_subnet.private[*].cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  value = aws_subnet.public[*].cidr_block
}
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "vpc_id" {
  value = aws_vpc.main.id
}
