resource "aws_ses_domain_identity" "email_domain" {
  domain = local.domain
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = var.hosted_zone_id
  name    = "_amazonses.${local.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.email_domain.verification_token]
}

# implement this resource after DNS delegation is in place to avoid terraform errors
resource "aws_ses_domain_identity_verification" "email_verification" {
  count  = var.dns_delegated == false ? 0 : 1
  domain = aws_ses_domain_identity.email_domain.id

  depends_on = [aws_route53_record.amazonses_verification_record]
}

# implement this resource after DNS delegation is in place to avoid terraform errors
resource "aws_ses_domain_dkim" "email_dkim" {
  count  = var.dns_delegated == false ? 0 : 1
  domain = aws_ses_domain_identity.email_domain.domain
}

# implement this resource after DNS delegation is in place to avoid terraform errors
resource "aws_route53_record" "amazonses_dkim_record" {
  count   = var.dns_delegated == false ? 0 : 3
  zone_id = var.hosted_zone_id
  name    = "${element(aws_ses_domain_dkim.email_dkim.*.dkim_tokens[0], count.index)}._domainkey.${local.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.email_dkim.*.dkim_tokens[0], count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_email_identity" "email_address" {
  email = "${local.email}@${var.domain}"
}

resource "aws_ses_email_identity" "tdr_email_address" {
  email = "aws_tdr_management@${var.domain}"
}
