
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "idp-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-west-1a", "us-west-1c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dns_support     = true
}

locals {
  eks_admin_roles = [
    {
      rolearn  = "arn:aws:iam::767397705569:role/AWSReservedSSO_AWSAdministratorAccess_35990becbf6cf54f"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1
      instance_types = ["t3.medium"]
    }
  }

  aws_auth_additional_roles = local.eks_admin_roles
}
