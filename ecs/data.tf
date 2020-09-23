data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "mgmt_account_number" {
  name = "/mgmt/management_account"
}

data "aws_efs_file_system" "efs_file_system" {
  file_system_id = var.file_system_id
}
