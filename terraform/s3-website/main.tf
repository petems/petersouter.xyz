provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "website" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

####
# Logging bucket
###
resource "aws_s3_bucket" "logs" {
  bucket = "${var.s3_bucket_name}-logs"
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "website" {
  bucket        = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access/"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "/"
    }
    redirect {
      replace_key_with = "index.html"
    }
  }
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.website.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_read.json
}

####
# CloudFront Bits
###
resource "aws_cloudfront_origin_access_identity" "website-cf-identity" {
  comment = "Website CloudFront identity"
}

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    # START: For PrettyURLS
    domain_name = "${var.s3_bucket_name}.s3-website-${var.region}.amazonaws.com"
    origin_id   = "myS3Origin"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    # END: For PrettyURLS

    # START: For UglyURLS
    # domain_name = "${aws_s3_bucket.website.bucket_domain_name}"
    # origin_id   = "myS3Origin"
    # s3_origin_config {
    #   origin_access_identity = "${aws_cloudfront_origin_access_identity.website-cf-identity.cloudfront_access_identity_path}"
    # }
    # END: For UglyURLS
  }

  # https://aws.amazon.com/cloudfront/pricing/
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Website CloudFront distribution"
  default_root_object = "index.html"

  aliases = [var.dns_record, var.alt_dns_record]

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "200"
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 120 # 2min
    default_ttl            = 120 # 2min
    max_ttl                = 300 # 5min
  }

  viewer_certificate {
    acm_certificate_arn      = var.ssl_cert_arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only" # Warning: Not using SNI costs $600/mo, so use SNI
  }
}

output "cloudfront_dns_name" {
  value = aws_cloudfront_distribution.website_distribution.domain_name
}

####
# DNS Bits. Only works with Route53.
###
data "aws_route53_zone" "main" {
  name = "${var.dns_zone}."
}

resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.dns_record}."
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

