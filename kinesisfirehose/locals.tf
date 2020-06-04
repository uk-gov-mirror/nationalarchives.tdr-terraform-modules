locals {
  workspace              = lower(terraform.workspace)
  environment            = local.workspace == "default" ? "mgmt" : local.workspace
  destination_bucket_arn = "arn:aws:s3:::${var.destination_bucket}"
  stream_name            = "${var.project}-${var.function}-${local.environment}"
}
