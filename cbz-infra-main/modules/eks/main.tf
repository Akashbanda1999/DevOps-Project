# Fetch Default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch All Subnets in the Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get Individual Subnet Details
data "aws_subnet" "subnet_1a" {
  id = data.aws_subnets.default.ids[0]
}

data "aws_subnet" "subnet_1b" {
  id = data.aws_subnets.default.ids[1]
}

data "aws_subnet" "subnet_1c" {
  id = data.aws_subnets.default.ids[2]
}
resource "aws_eks_cluster" "cbz_cluster" {
  name     = "cbz-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.subnet_1a.id,
      data.aws_subnet.subnet_1b.id,
      data.aws_subnet.subnet_1c.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy
  ]
}

resource "aws_eks_node_group" "cbz_nodegroup" {
  cluster_name    = aws_eks_cluster.cbz_cluster.name
  node_group_name = "cbz-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    data.aws_subnet.subnet_1a.id,
    data.aws_subnet.subnet_1b.id,
    data.aws_subnet.subnet_1c.id
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
