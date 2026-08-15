terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket       = "tech-challenge-3-506570851351-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
