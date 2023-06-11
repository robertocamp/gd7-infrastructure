terraform {
  source = "../../../infrastructure-modules/vpc"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  env             = "live-infrastructure-v3"
  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.0.128.0/19", "10.0.160.0/19"]
  public_subnets  = ["10.0.192.0/19", "10.0.224.0/19"]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/dev-demo"  = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"         = 1
    "kubernetes.io/cluster/dev-demo" = "owned"
  }
}