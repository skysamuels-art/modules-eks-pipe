
output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}


output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.main.arn
}

