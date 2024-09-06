# ECSのRoleを作成する
# {
#   "Version" : "2012-10-17",
#   "Statement" : [
#     {
#       "Effect" : "Allow",
#       "Action" : [
#         "ecr:GetAuthorizationToken",
#         "ecr:BatchCheckLayerAvailability",
#         "ecr:GetDownloadUrlForLayer",
#         "ecr:BatchGetImage",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource" : "*"
#     }
#   ]
# }

# ECS実行ロールのポリシードキュメントを定義
data "aws_iam_policy_document" "ecs_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

# ECS実行ロールを作成
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy" "ecs_execution_policy" {
  name = "ecs_execution_policy"
  role = aws_iam_role.ecs_execution_role.id
  policy = data.aws_iam_policy_document.ecs_execution_policy.json
}
