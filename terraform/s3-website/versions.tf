terraform {
  required_version = ">= 1.16.6"

  backend "s3" {
    bucket       = "petersouter.xyz-terraform-state"
    key          = "s3-website/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.69.1, < 7.0"
    }
  }
}
