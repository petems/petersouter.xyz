variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for website hosting"
  type        = string
  default     = "petersouter.xyz"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "petersouter-website"
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "github_repository" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  default     = "petems/petersouter.xyz"
}

variable "enable_cloudfront_invalidation" {
  description = "Whether to enable CloudFront invalidation permissions"
  type        = bool
  default     = false
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  type        = string
  default     = ""
}
