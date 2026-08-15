variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "tech-challenge-3"
}

variable "environment" {
  description = "The environment for the project"
  type        = string
  default     = "dev"
}