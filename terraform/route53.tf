# Route53
resource "aws_route53_zone" "route53_zone" {
  name          = var.domain
  force_destroy = false
  tags = {
    Name   = "${var.project}-route53"
    Domain = var.domain
  }
}

# resource "aws_route53_record" "route53_record" {
  
# }
