# ensures compliance with CIS AWS Foundation Benchmark
resource "aws_iam_account_password_policy" "cis_benchmark" {
  count                          = var.aws_account_level == true ? 1 : 0
  minimum_password_length        = 14
  max_password_age               = 90
  password_reuse_prevention      = 24
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

# ensures compliance with CIS AWS Foundation Benchmark requirement for support role to be attached
resource "aws_iam_group" "support" {
  count = var.aws_account_level == true ? 1 : 0
  name  = var.support_group
  path  = "/group/"
}

# ensures compliance with CIS AWS Foundation Benchmark requirement for support role to be attached
resource "aws_iam_group_policy_attachment" "support_policy_attach" {
  count      = var.aws_account_level == true ? 1 : 0
  group      = aws_iam_group.support.*.name[0]
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}
