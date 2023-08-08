#resource "aws_s3_bucket_policy" "allow_access_to_specific_vpce_only" {
#  bucket = aws_s3_bucket.pete_bucket.id
#  policy = jsonencode({
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#        "Sid": "Access-to-specific-VPCE-only",
#        "Principal": "*",
#        "Action": "s3:*",
#        "Effect": "Deny",
#        "Resource": ["${aws_s3_bucket.pete_bucket.arn}",
#                    "${aws_s3_bucket.pete_bucket.arn}/*"],
#        "Condition": {
#            "StringNotEquals": {
#            "aws:SourceVpce": "${aws_vpc.pete_vpc.id}"
#            }
#        }
#    }
#    ]
#  })
#}


# Customer managed KMS key
resource "aws_kms_key" "kms_s3_key" {
    description             = "Key to protect S3 objects"
    key_usage               = "ENCRYPT_DECRYPT"
    deletion_window_in_days = 7
    is_enabled              = true
}

resource "aws_kms_alias" "kms_s3_key_alias" {
    name          = "alias/s3-key"
    target_key_id = aws_kms_key.kms_s3_key.key_id
}


resource "aws_s3_bucket" "pete_bucket" {
    bucket = var.bucket
    tags   = {
      Name = "pete_bucket"
    }
}



# Bucket private access
resource "aws_s3_bucket_acl" "pete_bucket_acl" {
  bucket = aws_s3_bucket.pete_bucket.id
  acl    = "private"
}


# Enable bucket versioning
resource "aws_s3_bucket_versioning" "pete_bucket_versioning" {
  bucket = aws_s3_bucket.pete_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}



# Enable default Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "pete_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.pete_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_s3_key.arn
        sse_algorithm     = "aws:kms"
    }
  }
}


# Creating Lifecycle Rule
resource "aws_s3_bucket_lifecycle_configuration" "pete_bucket_lifecycle_rule" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.pete_bucket_versioning]

  bucket = aws_s3_bucket.pete_bucket.bucket

  rule {
    id = "basic_config"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}


# Disabling bucket
# public access

resource "aws_s3_bucket_public_access_block" "pete_bucket_access" {
  bucket = aws_s3_bucket.pete_bucket.id

  # Block public access
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#Enforce Tls
resource "aws_s3_bucket_policy" "pete_bucket" {
    bucket = aws_s3_bucket.pete_bucket.id
    policy = jsonencode({
        Version = "2012-10-17"
        Id      = "BUCKET-POLICY"
        Statement = [
            {
                Sid       = "EnforceTls"
                Effect    = "Deny"
                Principal = "*"
                Action    = "s3:*"
                Resource = [
                    "arn:aws:s3:::intuitivecloudpete/*",
                    "arn:aws:s3:::intuitivecloudpete",
                ]
                Condition = {
                    Bool = {
                        "aws:SecureTransport" = "false"
                    }
                }
            }
        ]
    })
}
