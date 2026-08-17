output "ecr_scan_notification_lambda_arn" {
  value = aws_lambda_function.notifications_lambda_function.*.arn
}

output "ecr_scan_lambda_arn" {
  value = aws_lambda_function.ecr_scan_lambda_function.*.arn
}

output "signed_cookies_arn" {
  value = local.signed_cookies_arn
}

output "create_users_lambda_security_group_id" {
  value = aws_security_group.create_db_users_lambda.*.id
}

output "create_keycloak_users_api_lambda_arn" {
  value = local.create_keycloak_user_api_arn
}

output "create_keycloak_users_s3_lambda_arn" {
  value = local.create_keycloak_user_s3_arn
}

output "rotate_keycloak_secrets_lambda_arn" {
  value = aws_lambda_function.rotate_keycloak_secrets_lambda_function.*.arn
}

output "notifications_lambda_role_arn" {
  value = aws_iam_role.notifications_lambda_iam_role.*.arn
}
