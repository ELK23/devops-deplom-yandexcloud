terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
}

provider "kubernetes" {
  config_path = "/home/veer/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "/home/veer/.kube/config"
  }
}

# Deploy Atlantis via Helm
resource "helm_release" "atlantis" {
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  namespace  = "atlantis"

  create_namespace = true

  set {
    name  = "orgWhitelist"
    value = "github.com/${var.github_repo}"
  }

  set {
    name  = "github.user"
    value = var.github_user
  }

  set {
    name  = "github.token"
    value = var.github_token
  }

  set {
    name  = "github.secret"
    value = var.webhook_secret
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "atlantis_ingress" {
  depends_on = [helm_release.atlantis]

  metadata {
    name      = "atlantis-ingress"
    namespace = "atlantis"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "atlantis.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "atlantis"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
