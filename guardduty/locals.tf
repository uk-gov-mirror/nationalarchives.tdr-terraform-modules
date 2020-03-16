locals {
  ip_set = replace(var.ip_set, ",", "\n")
  region = data.aws_region.current.name
}