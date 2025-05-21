provider "aws" {
  region = "us-east-1"
}

# IAM Role for the EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# IAM Role for the Node Group
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to Node Group Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Data for Default VPC and Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "public_subnet_1a" {
  id = data.aws_subnet_ids.default.ids[0]
}

data "aws_subnet" "public_subnet_1b" {
  id = data.aws_subnet_ids.default.ids[1]
}

data "aws_subnet" "public_subnet_1c" {
  id = data.aws_subnet_ids.default.ids[2]
}

# EKS Cluster
resource "aws_eks_cluster" "cbz_cluster" {
  name     = "cbz-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.public_subnet_1a.id,
      data.aws_subnet.public_subnet_1b.id,
      data.aws_subnet.public_subnet_1c.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "cbz_nodegroup" {
  cluster_name    = aws_eks_cluster.cbz_cluster.name
  node_group_name = "cbz-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    data.aws_subnet.public_subnet_1a.id,
    data.aws_subnet.public_subnet_1b.id,
    data.aws_subnet.public_subnet_1c.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_policy
  ]
}

# Output cluster endpoint and OIDC
output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.cbz_cluster.endpoint
  description = "EKS Cluster Endpoint"
}

output "kubeconfig_hint" {
  value       = "Run this command: aws eks update-kubeconfig --name cbz-cluster"
  description = "Kubeconfig setup command"
}
