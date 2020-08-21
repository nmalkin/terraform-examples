provider "aws" {
  alias  = "acm"
  region = "us-east-1" # Cloudfront certificates have to be in us-east-1, regardless of where everything else is
}

data "aws_route53_zone" "domain_zone" {
  name         = var.root_zone
  private_zone = false
}

resource "aws_acm_certificate" "certificate" {
  provider    = aws.acm
  domain_name = var.domain
  # subject_alternative_names = ["*.${var.domain}"]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    owner = var.owner
  }
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain_zone.zone_id
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}
