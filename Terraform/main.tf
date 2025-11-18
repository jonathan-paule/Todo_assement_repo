terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = var.tf_state_bucket
    key    = var.tf_state_key
    region = var.region
  }
}

provider "aws" {
  region = var.region
}

