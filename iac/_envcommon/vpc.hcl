terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.8.1"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.env
  vpc_cidr = local.env_vars.locals.vpc_cidr
}

inputs = {
  name = "gitops-vpc-${local.env}"
  cidr = local.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = [for i in [1, 2, 3] : cidrsubnet(local.vpc_cidr, 4, i)]
  public_subnets  = [for i in [4, 5, 6] : cidrsubnet(local.vpc_cidr, 4, i)]

  enable_nat_gateway   = true
  single_nat_gateway   = local.env == "dev" ? true : false
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
