output "ses_arn" {
  value = aws_ses_domain_identity.email_domain.arn
}