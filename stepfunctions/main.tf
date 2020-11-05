resource "aws_sfn_state_machine" "state_machine" {
  definition = templatefile("${path.module}/templates/${var.definition}_definition.json.tpl", merge(var.definition_variables, { account_id = data.aws_caller_identity.current.account_id }))
  name       = "${upper(var.project)}${var.name}${title(var.environment)}"
  role_arn   = aws_iam_role.state_machine_role.arn
  tags       = var.common_tags
}

resource "aws_iam_role" "state_machine_role" {
  name               = "TDR${var.name}Role${title(var.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/assume_role.json.tpl", {})
}

resource "aws_iam_policy" "state_machine_policy" {
  name   = "TDR${var.name}Policy${title(var.environment)}"
  policy = templatefile("${path.module}/templates/${var.policy}_policy.json.tpl", merge(var.policy_variables, { account_id = data.aws_caller_identity.current.account_id }))
}

resource "aws_iam_role_policy_attachment" "state_machine_attachment" {
  policy_arn = aws_iam_policy.state_machine_policy.arn
  role       = aws_iam_role.state_machine_role.id
}
