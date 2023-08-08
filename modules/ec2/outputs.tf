# Getting arn of EC2 instance
output "Instance_pete1_arn" {
  value = aws_instance.pete_instance["pete1"].arn
}

output "Instance_pete2_arn" {
  value = aws_instance.pete_instance["pete2"].arn
}
