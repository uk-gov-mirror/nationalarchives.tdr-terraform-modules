locals {
  count = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
}