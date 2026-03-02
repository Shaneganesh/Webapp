# =============================================================
#  terraform/outputs.tf
# =============================================================

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.webapp.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.webapp.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.webapp.endpoint
}

output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.webapp.name
}

output "github_connection_arn" {
  description = "Complete the GitHub connection manually in the AWS Console"
  value       = aws_codestarconnections_connection.github.arn
}

output "artifact_bucket" {
  description = "S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.pipeline_artifacts.bucket
}
