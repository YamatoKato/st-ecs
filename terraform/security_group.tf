# Security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-alb"
  }
}

# Ingress rule for ALB
# HTTP TCP 80と HTTPS TCP 433ポート
resource "aws_security_group_rule" "alb_in_http_port80" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_in_https_port443" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Egress rule for ALB
resource "aws_security_group_rule" "alb_eg" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# sg for ecs service
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project}-ecs-service"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-ecs-service"
  }
}

# Ingress rule for ECS service
# 8080と8070ポート
resource "aws_security_group_rule" "ecs_in_frontend_port8080" {
  security_group_id        = aws_security_group.ecs_sg.id
  type                     = "ingress"
  from_port                = 8080 # ポート番号
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_in_backend_port8070" {
  security_group_id        = aws_security_group.ecs_sg.id
  type                     = "ingress"
  from_port                = 8070
  to_port                  = 8070
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

# Egress rule for ECS service
resource "aws_security_group_rule" "ecs_eg" {
  security_group_id = aws_security_group.ecs_sg.id
  type              = "egress"
  from_port         = 0 # ポート番号 0 から 65535 まで (全てのポート) を指定
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] # 全てのIPアドレスへのアクセスを許可
}

# private link security group
resource "aws_security_group" "private_link_sg" {
  name        = "${var.project}-private-link"
  description = "Security group for private link"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-private-link"
  }
}

# Ingress rule for private link
resource "aws_security_group_rule" "private_link_in_https" {
  security_group_id        = aws_security_group.private_link_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
}

# Egress rule for private link
resource "aws_security_group_rule" "private_link_eg" {
  security_group_id = aws_security_group.private_link_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
