terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.8.5"
}

locals {
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env             = local.env_vars.locals.env
  cluster_version = local.env_vars.locals.cluster_version
  instance_types  = local.env_vars.locals.instance_types
  min_size        = local.env_vars.locals.min_size
  max_size        = local.env_vars.locals.max_size
  desired_size    = local.env_vars.locals.desired_size
  is_prod         = local.env == "prod"
}

inputs = {
  cluster_name    = "gitops-eks-${local.env}"
  cluster_version = local.cluster_version

  # endpoint público desabilitado em prod — acesso via VPN ou AWS PrivateLink
  cluster_endpoint_public_access  = !local.is_prod
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    general = {
      min_size       = local.min_size
      max_size       = local.max_size
      desired_size   = local.desired_size
      instance_types = local.instance_types
      capacity_type  = local.env == "dev" ? "SPOT" : "ON_DEMAND"
    }
  }
}
