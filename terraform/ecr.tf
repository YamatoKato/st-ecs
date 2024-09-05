# ECR
# webapp
resource "aws_ecr_repository" "ecs_webapp" {
  name = "ecs_webapp"
  image_tag_mutability = "MUTABLE"
}

# backend
resource "aws_ecr_repository" "ecs_backend" {
  name = "ecs_backend"
  image_tag_mutability = "MUTABLE"
}

# restapi
resource "aws_ecr_repository" "ecs_restapi" {
  name = "ecs_restapi"
  image_tag_mutability = "MUTABLE"
}

