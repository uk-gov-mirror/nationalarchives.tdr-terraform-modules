resource "aws_ses_domain_identity" "email_domain" {
  domain = var.environment_full_name == "production" ? "${var.project}.${var.domain}" : "${var.project}-${var.environment_full_name}.${var.domain}"
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = var.hosted_zone_id
  name    = var.environment_full_name == "production" ? "_amazonses.${var.project}.${var.domain}" : "_amazonses.${var.project}-${var.environment_full_name}.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.email_domain.verification_token]
}

resource "aws_ses_domain_identity_verification" "email_verification" {
  domain = aws_ses_domain_identity.email_domain.id

  depends_on = [aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_email_identity" "from_address" {
  email    = var.environment_full_name == "production" ? "${var.from_address}@${var.project}.${var.domain}" : "${var.from_address}@${var.project}-${var.environment_full_name}.${var.domain}"
}
