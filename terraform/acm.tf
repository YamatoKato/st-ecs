# ACM
# katooon.netと*.katooon.netの証明書を作成します。

# これは証明書を作成するためのリソースです。
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method = "DNS"
  
  tags = {
    Name = "${var.project}-wildcard-sslcert"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }

  depends_on = [ 
    aws_route53_zone.route53_zone
   ]
}

# これは証明書の検証を行うためのリソースで、Route 53 レコードを作成します。
resource "aws_route53_record" "route53_acm_dns_validation" {
  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record   = dvo.resource_record_value
    }
  }


  zone_id         = aws_route53_zone.route53_zone.id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl = 600
  allow_overwrite = true
}

# これは証明書の検証を行います。
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_acm_dns_validation : record.fqdn ]
}
