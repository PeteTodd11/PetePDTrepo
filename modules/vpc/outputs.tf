# Getting VPC ID
output "vpc_id" {
  value = aws_vpc.pete_vpc.id
}

# Getting Subnet ID
output "subnet_id" {
  value = aws_subnet.pete_subnet.id
}
