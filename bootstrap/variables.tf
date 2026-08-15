variable "aws_region" {
  description = "AWS region containing the Terraform state bucket"
  type        = string
  default     = "us-east-2"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket"
  type        = string
  default     = "tech-challenge-3-506570851351-tfstate"
}
