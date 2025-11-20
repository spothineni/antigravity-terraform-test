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
        # tags are not supported in the filter block for lifecycle rules in the aws provider
      }))
      expiration = optional(object({
        days = optional(number)
        date = optional(string)
        expired_object_delete_marker = optional(bool)
      }))
      transition = optional(list(object({
        days          = optional(number)
        date          = optional(string)
        storage_class = string
      })))
      noncurrent_version_expiration = optional(object({
        noncurrent_days = optional(number)
        newer_noncurrent_versions = optional(number)
      }))
      noncurrent_version_transition = optional(list(object({
        noncurrent_days = optional(number)
        newer_noncurrent_versions = optional(number)
        storage_class   = string
      })))
      abort_incomplete_multipart_upload = optional(object({
        days_after_initiation = number
      }))
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

    replication_configuration = optional(object({
      role = string
      rules = list(object({
        id       = optional(string)
        priority = optional(number)
        status   = string
        delete_marker_replication = optional(object({
          status = string
        }))
        filter = optional(object({
          prefix = optional(string)
          tags   = optional(map(string))
        }))
        destination = object({
          bucket        = string
          storage_class = optional(string)
          account       = optional(string)
          access_control_translation = optional(object({
            owner = string
          }))
          encryption_configuration = optional(object({
            replica_kms_key_id = string
          }))
          metrics = optional(object({
            status = string
            event_threshold = optional(object({
              minutes = number
            }))
          }))
          replication_time = optional(object({
            status = string
            time = object({
              minutes = number
            })
          }))
        })
        source_selection_criteria = optional(object({
          sse_kms_encrypted_objects = optional(object({
            status = string
          }))
        }))
      }))
    }))

    object_lock_configuration = optional(object({
      object_lock_enabled = string
      rule = optional(object({
        default_retention = object({
          mode  = string
          days  = optional(number)
          years = optional(number)
        })
      }))
    }))
  })
}
