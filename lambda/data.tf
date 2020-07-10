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
  count = var.project == "tdr" && var.lambda_file_format ? 1 : 0
  name  = "/${local.environment}/keycloak/backend_checks_client/secret"
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
