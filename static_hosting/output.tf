output "bucket_domain" {
  value = [aws_s3_bucket.site.website_domain, aws_s3_bucket.site.website_endpoint, aws_s3_bucket.site.website, aws_s3_bucket.site.bucket_domain_name, aws_s3_bucket.site.bucket_regional_domain_name]
}
