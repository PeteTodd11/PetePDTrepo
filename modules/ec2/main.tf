#resource "aws_security_group" "pete" {
#  name        = "pete"
#  description = "Allow inbound traffic for web tier"
#  vpc_id      = var.vpc_id
#}
#
#resource "aws_security_group_rule" "web" {
#  security_group_id = aws_security_group.pete.id
#
#  type        = "ingress"
#  from_port   = 443
#  to_port     = 443
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#}
#
#resource "aws_security_group_rule" "web_ssh" {
#  security_group_id = aws_security_group.pete.id
#
#  type        = "ingress"
#  from_port   = 22
#  to_port     = 22
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"] # Replace with your desired CIDR blocks for SSH access
#}


resource "aws_instance" "pete_instance" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = data.aws_availability_zones.az.names[0]
  subnet_id              = var.subnet_id
#  vpc_security_group_ids = [aws_security_group.pete.id]
  for_each          = var.pete_instance


  tags = {
      "Name" = "${var.name}-instance"
    }
  }

# AZ
data "aws_availability_zones" "az" {}



resource "aws_ebs_volume" "pete" {
  for_each          = aws_instance.pete_instance

  availability_zone = aws_instance.pete_instance[each.key].availability_zone
  size              = var.drive_size
}


resource "aws_volume_attachment" "pete" {
  for_each          = aws_instance.pete_instance
  device_name       = "/dev/sdh"
  volume_id         = aws_ebs_volume.pete[each.key].id
  instance_id       = aws_instance.pete_instance[each.key].id
}
