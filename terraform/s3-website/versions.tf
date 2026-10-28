terraform {
  required_version = ">= 1.17.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.69.1, < 7.0"
    }
  }
}
