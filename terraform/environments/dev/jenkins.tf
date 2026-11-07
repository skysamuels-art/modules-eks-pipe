module "jenkins" {
  source = "../../modules/jenkins"

  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  key_pair_name        = "skysams"
  admin_cidrs          = var.public_access_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

output "jenkins_public_ip" {
  value = module.jenkins.public_ip
}

output "jenkins_private_ip" {
  value = module.jenkins.private_ip
}