variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "s3_bucket_name" {
  type    = string
  default = "petersouter.xyz"
}

variable "ssl_cert_arn" {
  type        = string
  description = "Used for CloudFront distribution point. Use Amazon Certificate Manager to create. Make sure to add all CNAMES: www.example.com, example.com, etc."
  default     = "arn:aws:acm:us-east-1:775684682517:certificate/0df1308a-2d77-458c-a190-45124a5b8b01"
}

variable "dns_zone" {
  type        = string
  description = "If using a sub domain like blog.example.com you should use example.com. root level just example.com"
  default     = "petersouter.xyz"
}

variable "dns_record" {
  type    = string
  default = "petersouter.xyz"
}

variable "alt_dns_record" {
  type    = string
  default = "www.petersouter.xyz"
}

variable "content_secret" {
  type        = string
  description = "Random string used to restrict S3 read access so CloudFront is used"
  default     = "1c3ae050-8446-45a8-8d1f-3ae92dc543c3"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "production"
    Project     = "website"
    ManagedBy   = "terraform"
  }
}

