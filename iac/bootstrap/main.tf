terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Backend local intencional: este módulo cria o backend remoto S3 usado pelos demais módulos.
  # Execute este módulo antes de qualquer 'terragrunt run-all'. Ver iac/bootstrap/README.md.
  backend "local" {}
}

variable "env" {
  description = "Nome do ambiente (dev, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

# Chave KMS gerenciada pelo cliente (Customer Managed Key - CMK)
resource "aws_kms_key" "tfstate_key" {
  description             = "KMS Key para criptografia do S3 bucket de tfstate"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform Bootstrap"
    Project     = "gitops-enterprise"
  }
}

resource "aws_s3_bucket" "tfstate" {
  bucket        = "gitops-tfstate-${var.env}-${var.aws_region}"
  force_destroy = var.env == "dev" ? true : false

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform Bootstrap"
    Project     = "gitops-enterprise"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstate_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tflock" {
  name         = "gitops-tflocks-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tfstate_key.arn
  }

  tags = {
    Environment = var.env
    ManagedBy   = "Terraform Bootstrap"
    Project     = "gitops-enterprise"
  }
}

output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}

output "tflock_table" {
  value = aws_dynamodb_table.tflock.name
}
