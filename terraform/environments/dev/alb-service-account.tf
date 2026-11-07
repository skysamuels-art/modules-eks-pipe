resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = module.eks.alb_controller_role_arn
    }
  }

  depends_on = [module.eks]
}