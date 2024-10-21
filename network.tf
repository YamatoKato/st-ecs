module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}c"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  public_subnet_names  = ["Public Subnet 1a", "Public Subnet 1c"]
  private_subnet_names = ["Private Subnet 1a", "Private Subnet 1c"]

  enable_dns_support   = true
  enable_dns_hostnames = true

  # IGW is created by default
  enable_nat_gateway = true # 各Public SubnetにNAT Gatewayを作成
}
