# S3 Bucket
resource "aws_s3_bucket" "bucket" {
  for_each = var.buckets

  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy
  tags          = each.value.tags

  # Object Lock must be enabled at bucket creation
  dynamic "object_lock_configuration" {
    for_each = each.value.object_lock != null && each.value.object_lock.enabled ? [1] : []
    content {
      object_lock_enabled = "Enabled"
    }
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  for_each = { for k, v in var.buckets : k => v if v.enable_versioning }

  bucket = aws_s3_bucket.bucket[each.key].id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = each.value.mfa_delete ? "Enabled" : "Disabled"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = { for k, v in var.buckets : k => v if v.encryption != null }

  bucket = aws_s3_bucket.bucket[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.encryption.algorithm
      kms_master_key_id = each.value.encryption.kms_key_id
    }
    bucket_key_enabled = each.value.encryption.bucket_key
  }
}

# Logging
resource "aws_s3_bucket_logging" "logging" {
  for_each = { for k, v in var.buckets : k => v if v.logging != null }

  bucket = aws_s3_bucket.bucket[each.key].id

  target_bucket = each.value.logging.target_bucket
  target_prefix = each.value.logging.target_prefix
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "public_access" {
  for_each = var.buckets

  bucket = aws_s3_bucket.bucket[each.key].id

  block_public_acls       = lookup(each.value.block_public_access, "block_public_acls", true)
  block_public_policy     = lookup(each.value.block_public_access, "block_public_policy", true)
  ignore_public_acls      = lookup(each.value.block_public_access, "ignore_public_acls", true)
  restrict_public_buckets = lookup(each.value.block_public_access, "restrict_public_buckets", true)
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  for_each = { for k, v in var.buckets : k => v if v.website != null }

  bucket = aws_s3_bucket.bucket[each.key].id

  index_document {
    suffix = each.value.website.index_document
  }

  dynamic "error_document" {
    for_each = each.value.website.error_document != null ? [1] : []
    content {
      key = each.value.website.error_document
    }
  }
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "cors" {
  for_each = { for k, v in var.buckets : k => v if length(v.cors_rules) > 0 }

  bucket = aws_s3_bucket.bucket[each.key].id

  dynamic "cors_rule" {
    for_each = each.value.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = { for k, v in var.buckets : k => v if length(v.lifecycle_rules) > 0 }

  bucket = aws_s3_bucket.bucket[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = rule.value.prefix != null ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_transitions
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

# Object Ownership Controls
resource "aws_s3_bucket_ownership_controls" "ownership" {
  for_each = var.buckets

  bucket = aws_s3_bucket.bucket[each.key].id

  rule {
    object_ownership = each.value.object_ownership
  }
}

# Bucket ACL
resource "aws_s3_bucket_acl" "acl" {
  for_each = { for k, v in var.buckets : k => v if v.acl != null }

  bucket = aws_s3_bucket.bucket[each.key].id
  acl    = each.value.acl

  depends_on = [aws_s3_bucket_ownership_controls.ownership]
}

# Bucket Policy
resource "aws_s3_bucket_policy" "policy" {
  for_each = { for k, v in var.buckets : k => v if v.policy_json != null }

  bucket = aws_s3_bucket.bucket[each.key].id
  policy = each.value.policy_json
}

# Replication Configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
  for_each = { for k, v in var.buckets : k => v if v.replication != null }

  bucket = aws_s3_bucket.bucket[each.key].id
  role   = each.value.replication.role_arn

  dynamic "rule" {
    for_each = each.value.replication.rules
    content {
      id       = rule.value.id
      status   = rule.value.status
      priority = rule.value.priority

      dynamic "filter" {
        for_each = rule.value.prefix != null ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class
        account       = rule.value.destination.account_id
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.versioning]
}

# Object Lock Configuration (default retention)
resource "aws_s3_bucket_object_lock_configuration" "lock" {
  for_each = { for k, v in var.buckets : k => v if v.object_lock != null && v.object_lock.enabled }

  bucket = aws_s3_bucket.bucket[each.key].id

  rule {
    default_retention {
      mode  = each.value.object_lock.mode
      days  = each.value.object_lock.days
      years = each.value.object_lock.years
    }
  }
}
