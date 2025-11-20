variable "buckets" {
  description = "Map of S3 bucket configurations"
  type = map(object({
    # Basic Configuration
    bucket_name   = string
    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})

    # Versioning
    enable_versioning = optional(bool, false)
    mfa_delete        = optional(bool, false)

    # Encryption
    encryption = optional(object({
      algorithm     = string           # AES256 or aws:kms
      kms_key_id    = optional(string) # Required if algorithm is aws:kms
      bucket_key    = optional(bool, true)
    }))

    # Access Logging
    logging = optional(object({
      target_bucket = string
      target_prefix = optional(string, "")
    }))

    # Public Access Block
    block_public_access = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }), {})

    # Static Website Hosting
    website = optional(object({
      index_document = string
      error_document = optional(string)
    }))

    # CORS Configuration
    cors_rules = optional(list(object({
      allowed_headers = optional(list(string), [])
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string), [])
      max_age_seconds = optional(number, 3000)
    })), [])

    # Lifecycle Rules
    lifecycle_rules = optional(list(object({
      id      = string
      enabled = bool
      prefix  = optional(string)

      expiration_days                    = optional(number)
      noncurrent_version_expiration_days = optional(number)

      transitions = optional(list(object({
        days          = number
        storage_class = string # STANDARD_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE
      })), [])

      noncurrent_transitions = optional(list(object({
        days          = number
        storage_class = string
      })), [])
    })), [])

    # Object Ownership
    object_ownership = optional(string, "BucketOwnerEnforced") # BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter

    # Bucket ACL (only if object_ownership allows)
    acl = optional(string) # private, public-read, public-read-write, authenticated-read

    # Bucket Policy
    policy_json = optional(string)

    # Replication
    replication = optional(object({
      role_arn = string
      rules = list(object({
        id       = string
        status   = string # Enabled or Disabled
        priority = optional(number)
        prefix   = optional(string)

        destination = object({
          bucket        = string # ARN
          storage_class = optional(string)
          account_id    = optional(string)
        })
      }))
    }))

    # Object Lock
    object_lock = optional(object({
      enabled = bool
      mode    = optional(string) # GOVERNANCE or COMPLIANCE
      days    = optional(number)
      years   = optional(number)
    }))
  }))
  default = {}
}
