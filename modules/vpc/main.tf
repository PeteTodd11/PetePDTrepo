# AWS VPC
resource "aws_vpc" "pete_vpc" {
 cidr_block           = var.cidr_block
 instance_tenancy     = var.tenancy
 enable_dns_hostnames = true
 enable_dns_support   = true

 tags = {
   "Name" = "${var.name}-vpc"
 }
}


# AZ
data "aws_availability_zones" "az" {}

# AWS Subnet
resource "aws_subnet" "pete_subnet" {
 vpc_id                  = aws_vpc.pete_vpc.id
 cidr_block              = var.cidr_block_subnet
 availability_zone       = data.aws_availability_zones.az.names[0]
 map_public_ip_on_launch = true

 tags = {
   "Name" = "${var.name}-subnet"
 }
}

# AWS Route Table
resource "aws_route_table" "pete_route_table" {
 vpc_id = aws_vpc.pete_vpc.id

 tags = {
   "Name" = "${var.name}-route"
 }
}

# Associate public subnet to route table
resource "aws_route_table_association" "pete_association" {
 subnet_id      = aws_subnet.pete_subnet.id
 route_table_id = aws_route_table.pete_route_table.id
}


resource "aws_vpc_endpoint" "gw_endpoint" {
    vpc_endpoint_type = "Gateway"
    vpc_id = aws_vpc.pete_vpc.id
    service_name = "com.amazonaws.us-east-1.s3"
    route_table_ids = [
        aws_route_table.pete_route_table.id
    ]
    private_dns_enabled = false

    tags = {
        Name = "s3_gateway_end_point"
    }
}


#resource "aws_vpc_endpoint_policy" "gw_endpoint_policy" {
#  vpc_endpoint_id = aws_vpc_endpoint.gw_endpoint.id
#  policy = jsonencode({
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#        "Sid": "Access-to-specific-s3-only",
#        "Principal": "*",
#        "Action": "s3:*",
#        "Effect": "Allow",
#        "Resource": ["${aws_s3_bucket.pete_bucket.arn}",
#                    "${aws_s3_bucket.pete_bucket.arn}/*"],
#        }
#    ]
#  })
#}

resource "aws_vpc_endpoint_route_table_association" "gw_endpoint_rt_association" {
  route_table_id  = aws_route_table.pete_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.gw_endpoint.id
}
