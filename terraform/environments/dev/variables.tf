
variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "project_name" {
  type    = string
  default = "eks-pipeline"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "availability_zones" {
  type = list(string)
  default = [
    "us-west-1a",
    "us-west-1b"
  ]
}

variable "repository_name" {
  type    = string
  default = "hello-world"
}

variable "cluster_name" {
  type    = string
  default = "tc2-eks"
}

variable "kubernetes_version" {
  type = string
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}

variable "desired_nodes" {
  type    = number
  default = 2
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 4
}

variable "public_access_cidrs" {
  type = list(string)
}


variable "iam_user_name" {
  description = "Existing IAM user receiving ECR permissions"
  type        = string
}

