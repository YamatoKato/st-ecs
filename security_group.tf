resource "aws_security_group" "alb" {
  name        = "${local.app}-alb-sg"
  description = "For ALB"
  vpc_id      = module.vpc.vpc_id

  # ALBへ入ってくるトラフィックは80番ポートのみ許可
  ingress {
    description = "Allow HTTP from ALL."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # どこからでも許可
  }
  # ALBから出ていくトラフィックは全て許可
  egress {
    description = "Allow all to outbound."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # どこへでも許可
  }
}

resource "aws_security_group" "ecs" {
  name        = "${local.app}-ecs-sg"
  description = "For ECS."
  vpc_id      = module.vpc.vpc_id

  # ECSコンテナの外部への通信をすべて許可する
  egress {
    description = "Allow all to outbound."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # どこへでも許可
  }
  tags = {
    Name = "${local.app}-ecs"
  }
}
# ECSコンテナに入ってくるトラフィックをALBのSecurity Groupからのトラフィック（8080番ポート）のみ許可
resource "aws_security_group_rule" "ecs_from_alb" {
  description              = "Allow 8080 from Security Group for ALB."
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id # ALBのSecurity Groupからのトラフィックを許可
  security_group_id        = aws_security_group.ecs.id
}
