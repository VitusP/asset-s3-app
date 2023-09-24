output "endpoint" {
  value = "${aws_s3_bucket.asset-app-bucket.bucket_domain_name}/index.html"
}