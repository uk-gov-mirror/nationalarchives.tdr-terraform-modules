output "public_ip" {
  value = aws_instance.instance.public_ip
}

output "instance_arn" {
  value = aws_instance.instance.arn
}

output "role_id" {
  value = aws_iam_role.ec2_role.id
}
