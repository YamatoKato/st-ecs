# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.project}-alb"
  internal           = false # これは外部向けのALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  # enable_deletion_protection = false これは、削除保護を無効にするための設定です。
  enable_http2 = true
  
}

# IP Target Group（仮）TODO
resource "aws_lb_target_group" "ip_target_group" {
  name     = "${var.project}-ip-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.vpc.id
}

# Listener_HTTP
# HTTPSにリダイレクトさせる
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  ssl_policy = "ELBSecurityPolicy-2016-08"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip_target_group.arn # TODO
  }
}

# Listener_HTTPS
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip_target_group.arn # TODO
  }
}

# aws_lb_listener_certificate
resource "aws_lb_listener_certificate" "cert" {
  listener_arn    = aws_lb_listener.listener_https.arn
  certificate_arn = aws_acm_certificate.acm_cert.arn
}

# aws_lb_listener_rule
resource "aws_lb_listener_rule" "https_redirect" {
  listener_arn = aws_lb_listener.listener_http.arn

  action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    http_header {
      http_header_name  = "X-Forwarded-Proto"
      values            = ["http"]
    }
  }
}


