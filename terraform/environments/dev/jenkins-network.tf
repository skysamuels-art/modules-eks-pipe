resource "aws_vpc_security_group_ingress_rule" "jenkins_to_eks" {
  security_group_id = module.eks.cluster_security_group_id

  referenced_security_group_id = module.jenkins.security_group_id

  description = "Allow Jenkins controller to reach EKS API"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}