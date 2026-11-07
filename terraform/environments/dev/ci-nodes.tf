resource "aws_eks_node_group" "ci" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "${var.cluster_name}-ci-nodes"
  node_role_arn   = module.eks.node_role_arn
  subnet_ids     = module.vpc.private_subnet_ids

  instance_types = ["t3.large"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 50

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    workload = "ci"
  }

  tags = {
    Name = "${var.cluster_name}-ci-nodes"
  }

  depends_on = [module.eks]
}