locals {
  env        = get_env("TG_ENV", "dev")
  aws_region = get_env("AWS_REGION", "us-east-1")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = {
      Environment = "${local.env}"
      ManagedBy   = "Terragrunt"
      Project     = "gitops-enterprise"
      Monorepo    = "true"
    }
  }
}
EOF
}

# Pré-requisito: execute 'cd iac/bootstrap && terraform apply' antes de usar este backend.
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "gitops-tfstate-${local.env}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "gitops-tflocks-${local.env}"
  }
}
