variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "s3_bucket_name" {
  type    = string
  default = "petersouter.xyz"
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
