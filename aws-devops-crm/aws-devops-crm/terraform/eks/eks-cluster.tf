# Terraform (terraform/eks/eks-cluster.tf)
module "eks" {
  source              = "terraform-aws-modules/eks/aws"
  eks_cluster_name    = "crm-eks-cluster"
  cluster_version     = "1.31"
  subnet_ids          = module.vpc.private_subnets
  vpc_id              = module.vpc.vpc_id
  eks_managed_node_groups = {
    default = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.medium"]
    }
  }

  manage_aws_auth = true
}

