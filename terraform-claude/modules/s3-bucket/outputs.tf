output "bucket_ids" {
  description = "Map of bucket keys to bucket IDs"
  value       = { for k, v in aws_s3_bucket.bucket : k => v.id }
}

output "bucket_arns" {
  description = "Map of bucket keys to bucket ARNs"
  value       = { for k, v in aws_s3_bucket.bucket : k => v.arn }
}

output "bucket_domain_names" {
  description = "Map of bucket keys to bucket domain names"
  value       = { for k, v in aws_s3_bucket.bucket : k => v.bucket_domain_name }
}

output "bucket_regional_domain_names" {
  description = "Map of bucket keys to bucket regional domain names"
  value       = { for k, v in aws_s3_bucket.bucket : k => v.bucket_regional_domain_name }
}

output "website_endpoints" {
  description = "Map of bucket keys to website endpoints"
  value = {
    for k, v in aws_s3_bucket_website_configuration.website : k => v.website_endpoint
  }
}
