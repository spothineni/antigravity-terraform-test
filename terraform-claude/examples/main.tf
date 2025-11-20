terraform {
  required_version = ">= 1.5.0"

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

locals {
  bucket_config = yamldecode(file("${path.module}/buckets.yaml"))
}

module "s3_buckets" {
  source = "../modules/s3-bucket"

  buckets = local.bucket_config.s3_buckets
}

output "all_buckets" {
  description = "All S3 bucket information"
  value = {
    ids                  = module.s3_buckets.bucket_ids
    arns                 = module.s3_buckets.bucket_arns
    domain_names         = module.s3_buckets.bucket_domain_names
    regional_domain_names = module.s3_buckets.bucket_regional_domain_names
    website_endpoints    = module.s3_buckets.website_endpoints
  }
}
