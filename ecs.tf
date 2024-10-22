resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = local.app
  network_mode             = "awsvpc" # Fargateの場合はawsvpcを指定
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]               # Fargateを指定
  execution_role_arn       = aws_iam_role.ecs.arn      # タスク実行時にアクセスしたい AWS リソースの権限を管理するための IAM ロール
  task_role_arn            = aws_iam_role.ecs_task.arn # タスク実行して起動したコンテナがアクセスしたい AWS リソースの権限を管理するための IAM ロール
  # NOTE: Dummy container for initial.
  # task定義
  container_definitions = <<CONTAINERS
[
  {
    "name": "${local.app}",
    "image": "medpeer/health_check:latest",
    "portMappings": [
      {
        "hostPort": 8080,
        "containerPort": 8080
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.cloudwatch_log_group.name}",
        "awslogs-region": "${local.region}",
        "awslogs-stream-prefix": "${local.app}"
      }
    },
    "environment": [
      {
        "name": "NGINX_PORT",
        "value": "8080"
      },
      {
        "name": "HEALTH_CHECK_PATH",
        "value": "/health_checks"
      }
    ]
  }
]
CONTAINERS
}

# ECSサービスの作成
# どのタスクを起動するか、どのクラスタに配置するか、何個配置するのか、どのサブネットに配置するか、どのセキュリティグループを使用するか、どのロードバランサーを使用するかを指定
resource "aws_ecs_service" "ecs_service" {
  name            = local.app
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2 # 起動するタスク数,2つのAZに1つずつ配置
  network_configuration {
    subnets         = module.vpc.private_subnets  # タスクを配置するサブネット
    security_groups = [aws_security_group.ecs.id] # タスクが使用するセキュリティグループ
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # ターゲットグループのARN
    container_name   = local.app
    container_port   = 8080
  }
  # aws_lb_listener_rule.alb_listener_rule リソースの作成が完了するのを待ってからサービスを作成
  depends_on = [aws_lb_listener_rule.alb_listener_rule]
}

# ECSクラスタの作成
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.app}-cluster"
}
