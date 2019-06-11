resource "aws_s3_bucket" "default" {
  provider = "${var.provider}"
  bucket = "${var.name}-logs"
  region = "${var.region}"
  acl    = "log-delivery-write"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    tags {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = "${var.transition_infrequent_days}"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "${var.transition_glacier_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = "${var.expiration_days}"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(var.tags, map(
    "Security", "SSE:AWS"
  ))}"
}
