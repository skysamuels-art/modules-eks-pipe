resource "kubernetes_service_account_v1" "jenkins_controller" {
  metadata {
    name      = "jenkins-controller"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }
}

resource "kubernetes_role_v1" "jenkins_controller" {
  metadata {
    name      = "jenkins-controller"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["get", "create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "jenkins_controller" {
  metadata {
    name      = "jenkins-controller"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.jenkins_controller.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.jenkins_controller.metadata[0].name
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }
}