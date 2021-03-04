data "aws_vpc" "consignment_export_current" {
  count = local.count_consignment_export
  tags = {
    Name = "tdr-vpc-${local.environment}"
  }
}

resource "aws_ecs_task_definition" "consignment_export_task_definition" {
  count = local.count_consignment_export
  container_definitions = templatefile(
    "${path.module}/templates/consignment_export.json.tpl", {
      log_group_name             = aws_cloudwatch_log_group.consignment_export_log_group[count.index].name,
      app_environment            = local.environment,
      management_account         = data.aws_ssm_parameter.mgmt_account_number.value,
      backend_client_secret_path = var.backend_client_secret_path
      clean_bucket               = var.clean_bucket
      output_bucket              = var.output_bucket
      api_url                    = "${var.api_url}/graphql"
      auth_url                   = var.auth_url
      region                     = var.aws_region
  })
  family                   = "consignment-export-${local.environment}"
  task_role_arn            = aws_iam_role.consignment_export_ecs_task[count.index].arn
  execution_role_arn       = aws_iam_role.consignment_export_ecs_execution[count.index].arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  volume {
    name = "consignmentexport"
    efs_volume_configuration {
      file_system_id = var.file_system_id
      root_directory = "/"
      authorization_config {
        iam             = "ENABLED"
        access_point_id = var.access_point.id
      }
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_ecs_cluster" "consignment_export_cluster" {
  count = local.count_consignment_export
  name  = "consignment_export_${local.environment}"
}

resource "aws_iam_role" "consignment_export_ecs_execution" {
  count              = local.count_consignment_export
  name               = "${upper(var.project)}ConsignmentExportECSExecutionRole${title(local.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})

  tags = merge(
    var.common_tags,
    map(
      "Name", "ce-ecs-execution-iam-role-${local.environment}",
    )
  )
}

resource "aws_iam_role" "consignment_export_ecs_task" {
  count              = local.count_consignment_export
  name               = "${upper(var.project)}ConsignmentExportEcsTaskRole${title(local.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})
  tags = merge(
    var.common_tags,
    map(
      "Name", "ce-ecs-execution-iam-role-${local.environment}",
    )
  )
}

resource "aws_iam_policy" "consignment_export_ecs_task_policy" {
  count  = local.count_consignment_export
  name   = "${upper(var.project)}ConsignmentExportECSTaskPolicy${title(local.environment)}"
  policy = templatefile("${path.module}/templates/consignment_export_task_policy.json.tpl", { environment = local.environment, titleEnvironment = title(local.environment), aws_region = var.aws_region, account = data.aws_caller_identity.current.account_id })
}

resource "aws_iam_policy" "consignment_export_ecs_execution_policy" {
  count  = local.count_consignment_export
  name   = "${upper(var.project)}ConsignmentExportECSExecutionPolicy${title(local.environment)}"
  policy = templatefile("${path.module}/templates/consignment_export_execution_policy.json.tpl", { log_group_arn = aws_cloudwatch_log_group.consignment_export_log_group[count.index].arn, file_system_arn = data.aws_efs_file_system.efs_file_system.arn, management_account_number = data.aws_ssm_parameter.mgmt_account_number.value })
}

resource "aws_iam_role_policy_attachment" "consignment_export_task_policy_attachment" {
  count      = local.count_consignment_export
  policy_arn = aws_iam_policy.consignment_export_ecs_task_policy[count.index].arn
  role       = aws_iam_role.consignment_export_ecs_task[count.index].id
}

resource "aws_iam_role_policy_attachment" "consignment_export_execution_policy_attachment" {
  count      = local.count_consignment_export
  policy_arn = aws_iam_policy.consignment_export_ecs_execution_policy[count.index].arn
  role       = aws_iam_role.consignment_export_ecs_execution[count.index].id
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  count      = local.count_consignment_export
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  role       = aws_iam_role.consignment_export_ecs_execution[count.index].id
}

resource "aws_cloudwatch_log_group" "consignment_export_log_group" {
  count             = local.count_consignment_export
  name              = "/ecs/consignment-export-${local.environment}"
  retention_in_days = 30
}

resource "aws_security_group" "consignment_export_ecs_run_efs" {
  count       = local.count_consignment_export
  name        = "consignment-export-allow-ecs-mount-efs"
  description = "Allow Consignment Export ECS task to mount EFS volume"
  vpc_id      = data.aws_vpc.consignment_export_current[count.index].id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "export-allow-ecs-mount-efs")
  )
}
