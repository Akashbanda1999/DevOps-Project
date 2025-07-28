# Terraform (terraform/eks/eks-cluster.tf)
module "eks" {
  source              = "terraform-aws-modules/eks/aws"
  eks_cluster_name    = "crm-eks-cluster"
  cluster_version     = "1.31"
  subnet_ids          = module.vpc.private_subnets
  vpc_id              = module.vpc.vpc_id
}
