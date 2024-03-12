# Configure the AWS provider
provider "aws" {
  region = "us-west-2" # Replace with your desired AWS region
}

# Create an S3 Bucket
resource "aws_s3_bucket" "app" {
  bucket = "my-unique-bucket-name-12345" # Replace with your desired bucket name (must be globally unique)
  acl    = "private"

  tags = {
    Name        = "AppBucket"
    Environment = "Dev"
  }
}

# (Optional) Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# (Optional) Add a bucket policy
resource "aws_s3_bucket_policy" "app" {
  bucket = aws_s3_bucket.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Principal = "*"
        Resource  = "${aws_s3_bucket.app.arn}/*"
      }
    ]
  })
}

# (Optional) Add a lifecycle rule
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  rule {
    id     = "expire-logs"
    status = "Enabled"

    expiration {
      days = 30
    }

    filter {
      prefix = "logs/"
    }
  }
}

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.app.bucket
}
