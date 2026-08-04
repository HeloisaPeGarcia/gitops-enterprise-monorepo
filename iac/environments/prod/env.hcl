locals {
  env             = "prod"
  vpc_cidr        = "10.20.0.0/16"
  cluster_version = "1.29"
  instance_types  = ["m5.large"]
  min_size        = 3
  max_size        = 10
  desired_size    = 3
}
