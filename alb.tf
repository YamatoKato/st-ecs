resource "aws_lb" "alb" {
  name               = "${local.app}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

# リスナーはALBに対してのリクエストを受け取り、ターゲットグループにルーティングする
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"   # ALBにリクエストを送るポート
  protocol          = "HTTP" # ALBにリクエストを送るプロトコル

  # ターゲットグループにアクセスしたときに、繋がらない場合は、ターゲットグループのステータスコードを返す
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}
resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn

  action {
    type             = "forward" # リクエストをターゲットグループに転送
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  # パスパターンが一致した場合に、リクエストをターゲットグループに転送
  condition {
    path_pattern {
      values = ["*"] # すべてのパスにマッチ
    }
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${local.app}-target-group"
  port        = 8080 # ECS on FargateのコンテナがListenしているポートに対してリクエストを送る
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  # ターゲットグループのヘルスチェック
  health_check {
    healthy_threshold = 3  # 3回連続でヘルシーだったらOK
    interval          = 30 # 30秒ごとにヘルスチェック
    path              = "/health_checks"
    protocol          = "HTTP"
    timeout           = 5 # 5秒以内にレスポンスが返ってこなかったらタイムアウト
  }
}
