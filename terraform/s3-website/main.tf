provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

####
# Website bucket
###
resource "aws_s3_bucket" "website" {
  bucket = var.s3_bucket_name
}

# ACLs are disabled; public access is granted by the bucket policy instead
resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public bucket policy is needed for S3 static website hosting (PrettyURLs)
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
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
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [aws_s3_bucket_public_access_block.website]
}

resource "aws_s3_bucket_logging" "website" {
  bucket        = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access/"

  # S3 needs the delivery permission in place before logging can be enabled
  depends_on = [aws_s3_bucket_policy.logs]
}

####
# Access logs bucket
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
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_logging" {
  statement {
    sid       = "S3ServerAccessLogsPolicy"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/s3-access/*"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.website.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.s3_logging.json
}

####
# TLS certificate (CloudFront requires us-east-1)
###
resource "aws_acm_certificate" "website" {
  region                    = "us-east-1"
  domain_name               = var.dns_record
  subject_alternative_names = [var.alt_dns_record]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_acm_certificate_validation" "website" {
  region                  = "us-east-1"
  certificate_arn         = aws_acm_certificate.website.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

####
# CloudFront Bits
###
resource "aws_cloudfront_function" "www_redirect" {
  name    = "petersouter-www-redirect"
  runtime = "cloudfront-js-2.0"
  comment = "301 ${var.alt_dns_record} to ${var.dns_record}"
  publish = true
  code    = templatefile("${path.module}/functions/www-redirect.js", { canonical_host = var.dns_record })
}

# Same TTLs as the old legacy forwarded_values settings, but via a cache
# policy (forwarded_values is deprecated). Brotli/gzip in the cache key lets
# CloudFront serve compressed variants.
resource "aws_cloudfront_cache_policy" "website" {
  name        = "petersouter-website"
  comment     = "Static site: no cookies, headers or query strings"
  min_ttl     = 120 # 2min
  default_ttl = 120 # 2min
  max_ttl     = 300 # 5min

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
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

    # START: For UglyURLS (also needs an aws_cloudfront_origin_access_control)
    # domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    # origin_id                = "myS3Origin"
    # origin_access_control_id = aws_cloudfront_origin_access_control.website.id
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
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "myS3Origin"
    compress               = true
    cache_policy_id        = aws_cloudfront_cache_policy.website.id
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.www_redirect.arn
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.website.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
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

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.alt_dns_record}."
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
