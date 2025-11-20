terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  s3_config = yamldecode(file("${path.module}/s3_config.yaml"))
}

module "s3_buckets" {
  source = "../modules/s3"

  for_each = { for bucket in local.s3_config.buckets : bucket.name => bucket }

  bucket_config = each.value
}

output "bucket_details" {
  value = {
    for k, v in module.s3_buckets : k => {
      id  = v.s3_bucket_id
      arn = v.s3_bucket_arn
    }
  }
}
