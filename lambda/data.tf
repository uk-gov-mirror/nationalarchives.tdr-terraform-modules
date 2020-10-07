data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "mgmt_account_number" {
  count = var.project == "tdr" ? 1 : 0
  name  = "/mgmt/management_account"
}

data "aws_ssm_parameter" "intg_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/intg_account"
}

data "aws_ssm_parameter" "staging_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/staging_account"
}

data "aws_ssm_parameter" "prod_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/prod_account"
}

data "aws_ssm_parameter" "backend_checks_client_secret" {
  count = var.project == "tdr" && var.use_efs ? 1 : 0
  name  = "/${local.environment}/keycloak/backend_checks_client/secret"
}

data "aws_vpc" "current" {
  count = local.count_efs
  tags = {
    Name = "${var.project}-vpc-${local.environment}"
  }
}

data "aws_availability_zones" "available" {}

data "aws_subnet" "efs_private_subnet_zero" {
  count = local.count_efs
  vpc_id = var.vpc_id
  tags = {
    Name = "tdr-efs-private-subnet-0-${local.environment}"
  }
}

data "aws_subnet" "efs_private_subnet_one" {
  count = local.count_efs
  vpc_id = var.vpc_id
  tags = {
    Name = "tdr-efs-private-subnet-1-${local.environment}"
  }
}
