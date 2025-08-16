terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
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

resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = "atlantis"
  }
}

resource "kubernetes_secret" "atlantis_vcs" {
  metadata {
    name      = "atlantis-vcs"
    namespace = kubernetes_namespace.atlantis.metadata[0].name
  }

  data = {
    token          = var.github_token
    webhook-secret = var.webhook_secret
  }
}

resource "helm_release" "atlantis" {
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  namespace  = kubernetes_namespace.atlantis.metadata[0].name
  version    = "4.5.0"
  timeout    = 600  # Increased timeout

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "ingress.enabled"
    value = "false"  # We're creating ingress separately
  }

  set {
    name  = "atlantis.repoConfig"
    value = yamlencode({
      repos = [{
        id                  = var.github_repo
        apply_requirements  = ["approved", "mergeable"]
        allowed_overrides   = ["apply_requirements"]
        allow_custom_workflows = true
      }]
    })
  }

  set {
    name  = "atlantis.github.user"
    value = var.github_user
  }

  set {
    name  = "atlantis.github.token"
    value = var.github_token
  }

  set {
    name  = "atlantis.github.secret"
    value = var.webhook_secret
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "persistence.enabled"
    value = "false"
  }
}

resource "kubernetes_ingress_v1" "atlantis" {
  metadata {
    name      = "atlantis"
    namespace = kubernetes_namespace.atlantis.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }

  spec {
    rule {
      host = "atlantis.158.160.59.41.nip.io"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "atlantis"
              port {
                number = 4141
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.atlantis]
}