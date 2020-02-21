locals {
  workspace            = lower(terraform.workspace)
  environment          = local.workspace == "default" ? "mgmt" : local.workspace
  standard_bucket_name = "${var.project}-${var.function}-${local.workspace}"
  global_bucket_name   = "${var.project}-${var.function}"
  bucket_name          = var.environment_suffix == true ? local.standard_bucket_name : local.global_bucket_name
}
