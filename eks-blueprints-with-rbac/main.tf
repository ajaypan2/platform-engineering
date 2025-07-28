
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.cluster_name
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_support     = true
  enable_dns_hostnames   = true
}

module "eks" {
  source  = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v5.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  managed_node_groups = {
    default = {
      desired_size    = 2
      min_size        = 1
      max_size        = 3
      instance_types  = ["t3.medium"]
    }
  }

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::767397705569:role/AWSReservedSSO_AWSAdministratorAccess_35990becbf6cf54f"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  manage_aws_auth_configmap = true
}
