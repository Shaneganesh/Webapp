# =============================================================
#  terraform/variables.tf
# =============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "webapp"
}

variable "github_repo" {
  description = "GitHub repo in format owner/repo-name"
  type        = string
  # Example: "shane-ganesh/webapp"
}

variable "github_branch" {
  description = "GitHub branch to trigger the pipeline"
  type        = string
  default     = "main"
}
