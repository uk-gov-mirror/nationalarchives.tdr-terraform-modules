locals {
  workspace           = lower(terraform.workspace)
  environment         = local.workspace == "default" ? "mgmt" : local.workspace
  efs_volume_name     = "${var.project}-${var.function}-${local.environment}"
  root_directory_path = "/mnt${var.access_point_path}"
}
