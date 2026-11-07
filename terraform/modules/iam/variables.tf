
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "iam_user_name" {
  description = "Existing IAM user name"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  type        = string
}
