resource "aws_ecr_repository" "ecr_repository" {
  name                 = local.app
  image_tag_mutability = "IMMUTABLE" # イメージのタグを変更不可にする
  force_delete         = true
  # 脆弱性スキャンを有効にする
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  # イメージが３０個を超えた場合、古いイメージを削除するポリシー
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
