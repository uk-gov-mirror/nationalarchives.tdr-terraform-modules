data aws_instance "target_instance" {
  filter {
    name   = "tag:Name"
    values = [var.instance_name]
  }
}