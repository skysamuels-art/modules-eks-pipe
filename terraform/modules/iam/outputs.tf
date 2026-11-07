
output "ecr_policy_arn" {
  description = "ARN of the ECR push policy"
  value       = aws_iam_policy.ecr_push.arn
}
