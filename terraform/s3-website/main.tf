provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "website" {
  bucket = var.s3_bucket_name
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

resource "aws_s3_bucket_logging" "website" {
  bucket = aws_s3_bucket.website.id

  target_bucket = aws_s3_bucket.website.id
  target_prefix = "log/"
}

# ACL configuration using grant blocks for public-read access
resource "aws_s3_bucket_acl" "website" {
  bucket = aws_s3_bucket.website.id

  access_control_policy {
    grant {
      grantee {
        id   = "80dccb758071c1453c1611cc8985731453cc48ce0db8758d1e899cb83bc6475e"
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
      permission = "READ"
    }

    owner {
      id = "80dccb758071c1453c1611cc8985731453cc48ce0db8758d1e899cb83bc6475e"
    }
  }
}

# START: For PrettyURLS
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = var.s3_bucket_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
      "Condition": {
         "StringEquals": {"aws:UserAgent": "${var.content-secret}"}
      }
    }
  ]
}
POLICY

}

# END: For PrettyURLS

# START: For UglyURLS
# resource "aws_s3_bucket_policy" "s3_bucket_policy" {
#   bucket = "${var.s3_bucket_name}"
#   policy =<<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": ["${aws_cloudfront_origin_access_identity.website-cf-identity.iam_arn}"]
#       },
#       "Action": "s3:*",
#       "Resource": ["arn:aws:s3:::${var.s3_bucket_name}/*"]
#     }
#   ]
# }
# POLICY
# }
# END: For UglyURLS

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

    custom_header {
      name  = "User-Agent"
      value = var.content-secret
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

