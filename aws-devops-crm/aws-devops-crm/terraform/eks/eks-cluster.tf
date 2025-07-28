# Terraform (terraform/eks/eks-cluster.tf)
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "crm-eks-cluster"
  cluster_version = "1.31"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
}
