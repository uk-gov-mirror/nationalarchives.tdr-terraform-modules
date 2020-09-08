data "aws_caller_identity" "current" {}
data "aws_kms_key" "efs_kms_key" {
  key_id = "alias/aws/elasticfilesystem"
}
data "aws_vpc" "current" {
  tags = {
    Name = "${var.project}-vpc-${local.environment}"
  }
}

data "aws_availability_zones" "available" {}

data "aws_nat_gateway" "main_zero" {
  tags = map("Name", "nat-gateway-0-tdr-${local.environment}")
}

data "aws_nat_gateway" "main_one" {
  tags = map("Name", "nat-gateway-1-tdr-${local.environment}")
}
