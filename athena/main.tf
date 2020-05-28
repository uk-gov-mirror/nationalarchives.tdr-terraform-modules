resource "aws_athena_database" "data" {
  count  = var.apply_resource == true ? 1 : 0
  name   = local.athena_name
  bucket = var.bucket

  encryption_configuration {
    encryption_option = "SSE_S3"
  }
}

resource "aws_athena_workgroup" "workgroup" {
  count = var.apply_resource == true ? 1 : 0
  name  = local.athena_name

  configuration {
    result_configuration {

      encryption_configuration {
        encryption_option = "SSE_S3"
      }

      output_location = "s3://${var.bucket}/results/"
    }
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", local.athena_name,
    )
  )
}

resource "aws_athena_named_query" "query" {
  count     = var.apply_resource == true ? length(var.queries) : 0
  name      = element(var.queries[*], count.index)
  workgroup = aws_athena_workgroup.workgroup.*.id[0]
  database  = aws_athena_database.data.*.name[0]
  query     = templatefile("./tdr-terraform-modules/athena/templates/${element(var.queries[*], count.index)}.sql.tpl", { account_id = data.aws_caller_identity.current.account_id, database_name = aws_athena_database.data.*.name[0] })
}
