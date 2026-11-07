
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.repository_name
}

module "eks" {
  source = "../../modules/eks"

  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_type  = var.node_instance_type
  desired_nodes       = var.desired_nodes
  min_nodes           = var.min_nodes
  max_nodes           = var.max_nodes
  public_access_cidrs = var.public_access_cidrs
}

# IAM module for ECR push permissions
module "iam" {
  source = "../../modules/iam"

  project_name       = var.project_name
  iam_user_name      = var.iam_user_name
  ecr_repository_arn = module.ecr.repository_arn
}
