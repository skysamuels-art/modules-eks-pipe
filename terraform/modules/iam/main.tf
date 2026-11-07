
# IAM policy allowing Docker image push/pull to ECR
resource "aws_iam_policy" "ecr_push" {
  name        = "${var.project_name}-ecr-push-policy"
  description = "Allow Docker image push and pull to ECR"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ECRAuthorization"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = var.ecr_repository_arn
      }
    ]
  })
}

# Attach policy to existing IAM user
resource "aws_iam_user_policy_attachment" "ecr_push" {
  user       = var.iam_user_name
  policy_arn = aws_iam_policy.ecr_push.arn
}
