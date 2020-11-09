data aws_caller_identity "current" {}

resource "aws_ssm_maintenance_window" "maintenance_window" {
  name     = var.name
  schedule = var.schedule
  duration = var.duration
  cutoff   = var.cutoff
  tags     = var.common_tags
}

resource "aws_ssm_maintenance_window_target" "maintenance_window_target" {
  resource_type = "INSTANCE"
  window_id     = aws_ssm_maintenance_window.maintenance_window.id
  targets {
    key    = "InstanceIds"
    values = [data.aws_instance.target_instance.id]
  }
}

resource "aws_ssm_maintenance_window_task" "maintenance_window_task" {
  max_concurrency  = 2
  max_errors       = 1
  priority         = 1
  service_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
  task_arn         = "AWS-RunShellScript"
  task_type        = "RUN_COMMAND"
  window_id        = aws_ssm_maintenance_window.maintenance_window.id

  targets {
    key    = "InstanceIds"
    values = [data.aws_instance.target_instance.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "commands"
        values = [var.command]
      }
    }
  }
}
