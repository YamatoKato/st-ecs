# 元のcloudformation
# ---
# AWSTemplateFormatVersion: '2010-09-09'
# Description: Template for ECS Lesson by sugar

# Mappings:
#   StackConfig:
#     VPC:
#       CIDR: 10.1.0.0/16
#     PublicSubnet1:
#       CIDR: 10.1.0.0/24
#     PublicSubnet2:
#       CIDR: 10.1.1.0/24
#     PrivateSubnet1:
#       CIDR: 10.1.2.0/24
#     PrivateSubnet2:
#       CIDR: 10.1.3.0/24

# Resources:
#   VPC:
#     Type: AWS::EC2::VPC
#     Properties:
#       CidrBlock: !FindInMap [ StackConfig, VPC, CIDR ]
#       EnableDnsSupport: true
#       EnableDnsHostnames: true
#       Tags:
#         - Key: Name
#           Value: ecs-lesson-vpc
#   InternetGateway:
#     Type: AWS::EC2::InternetGateway
#     Properties:
#       Tags:
#         - Key: Name
#           Value: ecs-lesson-vpc-igw
#   AttachGateway:
#     Type: AWS::EC2::VPCGatewayAttachment
#     Properties:
#       VpcId: !Ref VPC
#       InternetGatewayId: !Ref InternetGateway
#   PublicRouteTable:
#     Type: AWS::EC2::RouteTable
#     DependsOn: AttachGateway
#     Properties:
#       VpcId: !Ref VPC
#       Tags:
#         - Key: Name
#           Value: ecs-lesson-public-route-table
#   PublicRoute:
#     Type: AWS::EC2::Route
#     DependsOn: AttachGateway
#     Properties:
#       RouteTableId: !Ref PublicRouteTable
#       DestinationCidrBlock: 0.0.0.0/0
#       GatewayId: !Ref InternetGateway
#   PublicSubnet1:
#     Type: AWS::EC2::Subnet
#     DependsOn: AttachGateway
#     Properties:
#       VpcId: !Ref VPC
#       AvailabilityZone: !Select [ 0, !GetAZs "" ]
#       CidrBlock: !FindInMap [ StackConfig, PublicSubnet1, CIDR ]
#       Tags:
#         - Key: Name
#           Value: Public Subnet 1
#   PublicSubnet1RouteTableAssociation:
#     Type: AWS::EC2::SubnetRouteTableAssociation
#     Properties:
#       SubnetId: !Ref PublicSubnet1
#       RouteTableId: !Ref PublicRouteTable
#   PublicSubnet2:
#     Type: AWS::EC2::Subnet
#     DependsOn: AttachGateway
#     Properties:
#       VpcId: !Ref VPC
#       AvailabilityZone: !Select [ 1, !GetAZs "" ]
#       CidrBlock: !FindInMap [ StackConfig, PublicSubnet2, CIDR ]
#       Tags:
#         - Key: Name
#           Value: Public Subnet 2
#   PublicSubnet2RouteTableAssociation:
#     Type: AWS::EC2::SubnetRouteTableAssociation
#     Properties:
#       SubnetId: !Ref PublicSubnet2
#       RouteTableId: !Ref PublicRouteTable
#   PrivateRouteTable1:
#     Type: AWS::EC2::RouteTable
#     Properties:
#       VpcId: !Ref VPC
#       Tags:
#         - Key: Name
#           Value: ecs-lesson-private-route-table-1
#   PrivateRouteTable2:
#     Type: AWS::EC2::RouteTable
#     Properties:
#       VpcId: !Ref VPC
#       Tags:
#         - Key: Name
#           Value: ecs-lesson-private-route-table-2
#   PrivateSubnet1:
#     Type: AWS::EC2::Subnet
#     Properties:
#       VpcId: !Ref VPC
#       AvailabilityZone: !Select [ 0, !GetAZs "" ]
#       CidrBlock: !FindInMap [ StackConfig , PrivateSubnet1 , CIDR ]
#       Tags:
#         - Key: Name
#           Value: Private Subnet 1
#   PrivateSubnet1RouteTableAssociation:
#     Type: AWS::EC2::SubnetRouteTableAssociation
#     Properties:
#       SubnetId: !Ref PrivateSubnet1
#       RouteTableId: !Ref PrivateRouteTable1
#   PrivateSubnet2:
#     Type: AWS::EC2::Subnet
#     Properties:
#       VpcId: !Ref VPC
#       AvailabilityZone: !Select [ 1, !GetAZs "" ]
#       CidrBlock: !FindInMap [ StackConfig , PrivateSubnet2 , CIDR ]
#       Tags:
#         - Key: Name
#           Value: Private Subnet 2
#   PrivateSubnet2RouteTableAssociation:
#     Type: AWS::EC2::SubnetRouteTableAssociation
#     Properties:
#       SubnetId: !Ref PrivateSubnet2
#       RouteTableId: !Ref PrivateRouteTable2

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = "10.1.0.0/16"
  enable_dns_support               = true
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "${var.project}-vpc"
  }
}

# Public Subnet1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-subnet1"
    Type = "Public"
  }
}

# Public Subnet2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-subnet2"
    Type = "Public"
  }
}

# Private Subnet1
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project}-private-subnet1"
    Type = "Private"
  }
}

# Private Subnet2
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.project}-private-subnet2"
    Type = "Private" # このサブネットがプライベートであることを示す
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "${var.project}-public-route-table"
    Reach = "Public" # このルートテーブルがパブリックアクセスを提供することを示す
  }
}

# Route Table Association for Public Subnet1
resource "aws_route_table_association" "public_rt_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association for Public Subnet2
resource "aws_route_table_association" "public_rt_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table for Private Subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "${var.project}-private-route-table"
    Reach = "Private" # このルートテーブルがプライベートアクセスを提供することを示す
  }
}

# Route Table Association for Private Subnet1
resource "aws_route_table_association" "private_rt_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

# Route Table Association for Private Subnet2
resource "aws_route_table_association" "private_rt_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}

# Route
resource "aws_route" "public_rt_igw_r" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


# Endpoints
# ECSのクラスターをPrivate Subnetに配置するため、他のリソースに対して通信するため、エンドポイントを作成
# 常時課金されるため、不要なエンドポイントは削除すること
# terraform destroy -target=aws_vpc_endpoint.vpc_ecs_endpoint -target=aws_vpc_endpoint.vpc_ecr_dki_endpoint -target=aws_vpc_endpoint.vpc_ecr_api_endpoint -target=aws_vpc_endpoint.vpc_secretsmanager_endpoint -target=aws_vpc_endpoint.vpc_ssm_endpoint -target=aws_vpc_endpoint.vpc_logs_endpoint -target=aws_vpc_endpoint.vpc_s3_gateway_endpoint

# ECR-dkr
# ECR は Elastic Container Registry の略で、Docker イメージを保存するためのサービスです。
resource "aws_vpc_endpoint" "vpc_ecr_dki_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true # エンドポイントのプライベートDNS名を有効にする
  security_group_ids = [aws_security_group.private_link_sg.id]
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  tags = {
    Name = "${var.project}-ecr-dkr-endpoint"
  }
}

# ECR-api
resource "aws_vpc_endpoint" "vpc_ecr_api_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_link_sg.id]
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  tags = {
    Name = "${var.project}-ecr-api-endpoint"
  }
}

# Secrets Manager
resource "aws_vpc_endpoint" "vpc_secretsmanager_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_link_sg.id]
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  tags = {
    Name = "${var.project}-secretsmanager-endpoint"
  }
}

# SSM
# SSM は Systems Manager の略で、AWS のサービスの一つです。EC2 インスタンスの管理やパッチ適用などを行う
resource "aws_vpc_endpoint" "vpc_ssm_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_link_sg.id]
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  tags = {
    Name = "${var.project}-ssm-endpoint"
  }
}

# Logs
# CloudWatch Logs は、AWS のログ管理サービスです。
resource "aws_vpc_endpoint" "vpc_logs_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_link_sg.id]
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  tags = {
    Name = "${var.project}-logs-endpoint"
  }
}

# S3-gateway
# Gateway エンドポイントは、VPC から S3 にアクセスするためのエンドポイントです。
resource "aws_vpc_endpoint" "vpc_s3_gateway_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private_rt.id, aws_route_table.public_rt.id]
  tags = {
    Name = "${var.project}-s3-gateway-endpoint"
  }
}
