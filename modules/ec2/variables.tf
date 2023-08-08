# Region
variable "region" {}

# AMI ID
variable "ami_id" {}

# Instance Type
variable "instance_type" {}

# Subnet ID
variable "subnet_id" {}

# Tags
variable "name" {}

# instances
variable "pete_instance" {
  type    = set(string)
  default = ["pete_1", "pete_2"]
}

# EBS Drive Size
variable "drive_size" {
  type    = number
  default = 20
}

#variable "vpc_id" {
#  type = string
#}
