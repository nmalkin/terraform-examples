provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "site" {
  bucket = var.domain

  website {
    index_document = "index.html"
  }

  tags = {
    owner = var.owner
  }
}

# via https://github.com/hashicorp/terraform/issues/5612#issuecomment-275912351
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# via https://stackoverflow.com/q/50389962 
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

# via https://www.terraform.io/docs/providers/aws/r/cloudfront_origin_access_identity.html#updating-your-bucket-policy
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}
