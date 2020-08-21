locals {
  s3_origin_id = "S3-${var.domain}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  aliases = [var.domain]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      cookies {
        forward = "all"
      }
      query_string = true
    }

    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-cachebehavior.html#cfn-cloudfront-distribution-cachebehavior-viewerprotocolpolicy
    viewer_protocol_policy = "redirect-to-https"

    # min_ttl = "${var.min_ttl}"
    # max_ttl = "${var.max_ttl}"
    # default_ttl = "${var.default_ttl}"
    compress = true
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn

    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-viewercertificate.html
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}



resource "aws_route53_record" "server_record" {
  zone_id = data.aws_route53_zone.domain_zone.zone_id
  name    = var.domain
  type    = "CNAME"
  ttl     = 60
  records = [aws_cloudfront_distribution.s3_distribution.domain_name]
}
