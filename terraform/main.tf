provider "aws" {
  region = var.region

  default_tags {
    tags = {
      hashicorp-learn = "circleci"
    }
  }
}

resource "random_uuid" "randomid" {}

resource "aws_s3_bucket" "asset-app-bucket" {
  tags = {
    Name          = "App Bucket"
    public_bucket = true
  }

  bucket        = "${var.app}.${var.label}.${random_uuid.randomid.result}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "asset-app-bucket" {
    bucket = aws_s3_bucket.asset-app-bucket.id
    acl    = "public-read"
    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.asset-app-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.asset-app-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "asset-app-bucket" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.asset-app-bucket.id
  content      = file("../assets/index.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "terramino" {
  bucket = aws_s3_bucket.asset-app-bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}