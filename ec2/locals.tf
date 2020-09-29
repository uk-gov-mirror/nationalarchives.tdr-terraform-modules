locals {
  iam_role_count = var.iam_policy != "" ? 1 : 0
}