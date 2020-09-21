resource "aws_ecs_task_definition" "file_format_build_task_definition" {
  count                    = local.count_file_format_build
  container_definitions    = templatefile("${path.module}/templates/file_format_build.json.tpl", { log_group_name = aws_cloudwatch_log_group.file_format_build_log_group[count.index].name, app_environment = local.environment, management_account = data.aws_ssm_parameter.mgmt_account_number.value })
  family                   = "file-format-build-${local.environment}"
  task_role_arn            = aws_iam_role.fileformat_ecs_task[count.index].arn
  execution_role_arn       = aws_iam_role.fileformat_ecs_execution[count.index].arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  volume {
    name = "fileformatbuild"
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

resource "aws_ecs_cluster" "file_format_build_cluster" {
  count = local.count_file_format_build
  name  = "file_format_build_${local.environment}"
}

resource "aws_iam_role" "fileformat_ecs_execution" {
  count              = local.count_file_format_build
  name               = "${upper(var.project)}FileFormatECSExecutionRole${title(local.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})

  tags = merge(
    var.common_tags,
    map(
      "Name", "ff-build-ecs-execution-iam-role-${local.environment}",
    )
  )
}

resource "aws_iam_role" "fileformat_ecs_task" {
  count              = local.count_file_format_build
  name               = "${upper(var.project)}FileFormatEcsTaskRole${title(local.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})
  tags = merge(
    var.common_tags,
    map(
      "Name", "ff-build-ecs-execution-iam-role-${local.environment}",
    )
  )
}

resource "aws_iam_policy" "file_format_ecs_task_policy" {
  count  = local.count_file_format_build
  name   = "${upper(var.project)}FileFormatECSTaskPolicy${title(local.environment)}"
  policy = templatefile("${path.module}/templates/file_format_task_policy.json.tpl", {})
}

resource "aws_iam_policy" "file_format_ecs_execution_policy" {
  count  = local.count_file_format_build
  name   = "${upper(var.project)}FileFormatECSExecutionPolicy${title(local.environment)}"
  policy = templatefile("${path.module}/templates/file_format_execution_policy.json.tpl", { log_group_arn = aws_cloudwatch_log_group.file_format_build_log_group[count.index].arn, file_system_arn = data.aws_efs_file_system.efs_file_system.arn, management_account_number = data.aws_ssm_parameter.mgmt_account_number.value })
}

resource "aws_iam_role_policy_attachment" "file_format_task_policy_attachment" {
  count      = local.count_file_format_build
  policy_arn = aws_iam_policy.file_format_ecs_task_policy[count.index].arn
  role       = aws_iam_role.fileformat_ecs_task[count.index].id
}

resource "aws_iam_role_policy_attachment" "file_format_execution_policy_attachment" {
  count      = local.count_file_format_build
  policy_arn = aws_iam_policy.file_format_ecs_execution_policy[count.index].arn
  role       = aws_iam_role.fileformat_ecs_execution[count.index].id
}

resource "aws_cloudwatch_log_group" "file_format_build_log_group" {
  count             = local.count_file_format_build
  name              = "/ecs/file-format-build-${local.environment}"
  retention_in_days = 30
}

resource "aws_security_group" "ecs_run_efs" {
  count       = local.count_file_format_build
  name        = "allow-ecs-mount-efs"
  description = "Allow ECS to mount EFS volume"
  vpc_id      = data.aws_vpc.current.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "allow-ecs-mount-efs")
  )
}