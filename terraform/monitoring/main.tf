# ==============================================================
# terraform/monitoring/main.tf
# AWS observability resources for SpendWise:
#   - CloudWatch Log Group  (/spendwise/app, 30-day retention)
#   - S3 Bucket             (CloudTrail logs, AES256, 90-day expiry)
#   - CloudTrail            (spendwise-trail, global events enabled)
#   - GuardDuty Detector    (enabled, FIFTEEN_MINUTES publish frequency)
#
# IMPORTANT – GuardDuty:
#   AWS allows only ONE detector per account per region.
#   If a detector already exists, import it before applying:
#     terraform import -var-file=../dev.tfvars \
#       module.monitoring.aws_guardduty_detector.main <detector-id>
# ==============================================================

# ---------------------------------------------------------------
# Dynamic account / region lookup (avoids hard-coding)
# ---------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==============================================================
# CloudWatch Log Group – application logs
# ==============================================================
resource "aws_cloudwatch_log_group" "app" {
  name              = "/spendwise/app"
  retention_in_days = 30

  tags = {
    Name        = "/spendwise/app"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==============================================================
# S3 Bucket – CloudTrail log storage
# ==============================================================
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "spendwise-cloudtrail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name        = "spendwise-cloudtrail"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption using AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle policy – expire logs after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "expire-logs-after-90-days"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# Bucket policy – allow CloudTrail to write logs
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  # public-access block must be in place before policy attachment
  depends_on = [aws_s3_bucket_public_access_block.cloudtrail]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ==============================================================
# CloudTrail – management event trail
# ==============================================================
resource "aws_cloudtrail" "main" {
  name                          = "spendwise-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  # Bucket policy must exist before the trail is created
  depends_on = [aws_s3_bucket_policy.cloudtrail]

  tags = {
    Name        = "spendwise-trail"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==============================================================
# GuardDuty Detector
# ==============================================================
resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = {
    Name        = "spendwise-guardduty"
    Environment = var.environment
    Project     = var.project_name
  }
}
