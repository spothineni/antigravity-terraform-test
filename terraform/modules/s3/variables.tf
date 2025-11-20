variable "bucket_config" {
  description = "Configuration for the S3 bucket"
  type = object({
    name        = string
    tags        = optional(map(string), {})
    force_destroy = optional(bool, false)
    
    versioning = optional(object({
      status     = string
      mfa_delete = optional(string)
    }))

    server_side_encryption_configuration = optional(object({
      rule = object({
        apply_server_side_encryption_by_default = object({
          sse_algorithm     = string
          kms_master_key_id = optional(string)
        })
        bucket_key_enabled = optional(bool)
      })
    }))

    logging = optional(object({
      target_bucket = string
      target_prefix = string
    }))

    lifecycle_rules = optional(list(object({
      id      = string
      status  = string
      filter  = optional(object({
        prefix = optional(string)
      }))
      expiration = optional(object({
        days = optional(number)
      }))
      transition = optional(list(object({
        days          = optional(number)
        storage_class = string
      })))
      noncurrent_version_expiration = optional(object({
        noncurrent_days = number
      }))
      noncurrent_version_transition = optional(list(object({
        noncurrent_days = number
        storage_class   = string
      })))
    })), [])

    public_access_block = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }))

    website = optional(object({
      index_document = optional(string)
      error_document = optional(string)
      redirect_all_requests_to = optional(string)
    }))

    cors_rules = optional(list(object({
      allowed_headers = optional(list(string))
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string))
      max_age_seconds = optional(number)
    })), [])

    ownership_controls = optional(object({
      rule = object({
        object_ownership = string
      })
    }))
    
    acl = optional(string)
    
    policy = optional(string)
  })
}
