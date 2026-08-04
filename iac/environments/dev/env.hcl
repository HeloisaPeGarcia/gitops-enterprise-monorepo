locals {
  env             = "dev"
  vpc_cidr        = "10.10.0.0/16"
  cluster_version = "1.29"
  instance_types  = ["t3.medium"]
  min_size        = 1
  max_size        = 3
  desired_size    = 2
}
