terraform {
  backend "s3" {
    bucket = "yk-aws-ecs-terraform-tfstate"
    key = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "yk-aws-ecs-terraform-tfstate-locking"
    encrypt        = true
  }
}
