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

resource "aws_ses_domain_identity_verification" "email_verification" {
  domain = aws_ses_domain_identity.email_domain.id

  depends_on = [aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_domain_dkim" "email_dkim" {
  domain = aws_ses_domain_identity.email_domain.domain
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count   = 3
  zone_id = var.hosted_zone_id
  name    = "${element(aws_ses_domain_dkim.email_dkim.dkim_tokens, count.index)}._domainkey.${local.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.email_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_email_identity" "email_address" {
  email = "${var.email_address}@${var.domain}"
}
