output "state_bucket_name" {
  description = "Name of the S3 bucket used by the root Terraform backend"
  value       = aws_s3_bucket.terraform_state.id
}
