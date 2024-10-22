# ECSがロールを引き継ぐためのIAMロールを作成する
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"] # AssumeRoleを許可
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"] # ECSタスクからのアクセスを許可
    }
  }
}
# ECSタスクロール用の IAM ロール
resource "aws_iam_role" "ecs_task" {
  name               = "${local.app}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

# 今回はタスクロールにはポリシーをアタッチしない





data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"] # ECSタスクからのアクセスを許可
    }
  }
}
# タスク実行時ロール用の IAM ロール
resource "aws_iam_role" "ecs" {
  name               = "${local.app}-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

# タスク実行ロール用の IAM ロールに適切なポリシーをアタッチ
# コンテナイメージを ECR から get して pull する
# CloudWatchLogs にログの出力先を作成し、ログを出力する
resource "aws_iam_role_policy_attachment" "ecs_basic" {
  role       = aws_iam_role.ecs.name # タスク実行ロール
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
