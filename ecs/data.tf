data "aws_caller_identity" "current" {}

data "aws_security_group" "ecs_task_security_group" {
  vpc_id = data.aws_vpc.current.id
  tags = {
    Name = "${var.project}-${var.app_name}-ecs-task-security-group-mgmt"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.current.id
  tags = {
    Name = "${var.project}-${var.app_name}-private-subnet-*-${local.environment}"
  }
}

data "aws_vpc" "current" {
  tags = {
    Name = var.vpc_tag_name
  }
}

data "aws_ssm_parameter" "mgmt_account_number" {
  name = "/mgmt/management_account"
}

data "aws_efs_file_system" "efs_file_system" {
  file_system_id = var.file_system_id
}
