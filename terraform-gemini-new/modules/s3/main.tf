resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_config.name
  force_destroy = var.bucket_config.force_destroy
  tags          = var.bucket_config.tags
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.bucket_config.versioning != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status     = var.bucket_config.versioning.status
    mfa_delete = var.bucket_config.versioning.mfa_delete
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.bucket_config.server_side_encryption_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.bucket_config.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm
      kms_master_key_id = var.bucket_config.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id
    }
    bucket_key_enabled = var.bucket_config.server_side_encryption_configuration.rule.bucket_key_enabled
  }
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.bucket_config.logging != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.bucket_config.logging.target_bucket
  target_prefix = var.bucket_config.logging.target_prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.bucket_config.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.bucket_config.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = expiration.value.days
          date                         = expiration.value.date
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition != null ? rule.value.transition : []
        content {
          days          = transition.value.days
          date          = transition.value.date
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days           = noncurrent_version_expiration.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition != null ? rule.value.noncurrent_version_transition : []
        content {
          noncurrent_days           = noncurrent_version_transition.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.bucket_config.public_access_block != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.bucket_config.public_access_block.block_public_acls
  block_public_policy     = var.bucket_config.public_access_block.block_public_policy
  ignore_public_acls      = var.bucket_config.public_access_block.ignore_public_acls
  restrict_public_buckets = var.bucket_config.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.bucket_config.website != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = var.bucket_config.website.index_document != null ? [1] : []
    content {
      suffix = var.bucket_config.website.index_document
    }
  }

  dynamic "error_document" {
    for_each = var.bucket_config.website.error_document != null ? [1] : []
    content {
      key = var.bucket_config.website.error_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.bucket_config.website.redirect_all_requests_to != null ? [1] : []
    content {
      host_name = var.bucket_config.website.redirect_all_requests_to
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.bucket_config.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.bucket_config.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = var.bucket_config.ownership_controls != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.bucket_config.ownership_controls.rule.object_ownership
  }
}

resource "aws_s3_bucket_acl" "this" {
  count  = var.bucket_config.acl != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  acl    = var.bucket_config.acl
  
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_config.policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_config.policy
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.bucket_config.replication_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = var.bucket_config.replication_configuration.role

  dynamic "rule" {
    for_each = var.bucket_config.replication_configuration.rules
    content {
      id       = rule.value.id
      priority = rule.value.priority
      status   = rule.value.status

      dynamic "delete_marker_replication" {
        for_each = rule.value.delete_marker_replication != null ? [rule.value.delete_marker_replication] : []
        content {
          status = delete_marker_replication.value.status
        }
      }

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix
          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class
        account       = rule.value.destination.account

        dynamic "access_control_translation" {
          for_each = rule.value.destination.access_control_translation != null ? [rule.value.destination.access_control_translation] : []
          content {
            owner = access_control_translation.value.owner
          }
        }

        dynamic "encryption_configuration" {
          for_each = rule.value.destination.encryption_configuration != null ? [rule.value.destination.encryption_configuration] : []
          content {
            replica_kms_key_id = encryption_configuration.value.replica_kms_key_id
          }
        }

        dynamic "metrics" {
          for_each = rule.value.destination.metrics != null ? [rule.value.destination.metrics] : []
          content {
            status = metrics.value.status
            dynamic "event_threshold" {
              for_each = metrics.value.event_threshold != null ? [metrics.value.event_threshold] : []
              content {
                minutes = event_threshold.value.minutes
              }
            }
          }
        }

        dynamic "replication_time" {
          for_each = rule.value.destination.replication_time != null ? [rule.value.destination.replication_time] : []
          content {
            status = replication_time.value.status
            dynamic "time" {
              for_each = replication_time.value.time != null ? [replication_time.value.time] : []
              content {
                minutes = time.value.minutes
              }
            }
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.source_selection_criteria != null ? [rule.value.source_selection_criteria] : []
        content {
          dynamic "sse_kms_encrypted_objects" {
            for_each = source_selection_criteria.value.sse_kms_encrypted_objects != null ? [source_selection_criteria.value.sse_kms_encrypted_objects] : []
            content {
              status = sse_kms_encrypted_objects.value.status
            }
          }
        }
      }
    }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.bucket_config.object_lock_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  object_lock_enabled = var.bucket_config.object_lock_configuration.object_lock_enabled

  dynamic "rule" {
    for_each = var.bucket_config.object_lock_configuration.rule != null ? [var.bucket_config.object_lock_configuration.rule] : []
    content {
      default_retention {
        mode  = rule.value.default_retention.mode
        days  = rule.value.default_retention.days
        years = rule.value.default_retention.years
      }
    }
  }
}
