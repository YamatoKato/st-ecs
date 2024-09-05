# ---------------------------
# Terraform configuration
# ---------------------------
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = "ap-northeast-1"
}

# Variables
variable "project" {
  description = "Project name"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}
