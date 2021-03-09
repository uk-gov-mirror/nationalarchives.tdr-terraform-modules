data "aws_caller_identity" "current" {}
data "aws_kms_key" "efs_kms_key" {
  key_id = "alias/aws/elasticfilesystem"
}

data "aws_availability_zones" "available" {}
