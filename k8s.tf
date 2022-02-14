terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# variable "host" {
#   type = string
# }

# variable "client_certificate" {
#   type = string
# }

# variable "client_key" {
#   type = string
# }

# variable "cluster_ca_certificate" {
#   type = string
# }

# provider "kubernetes" {
#   host = var.host

#   client_certificate     = base64decode(var.client_certificate)
#   client_key             = base64decode(var.client_key)
#   cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
# }

provider "kubernetes" {
  config_path = "~/.kube/config"  
}

resource "kubernetes_deployment" "web-app" {
  metadata {
    name = "web-app"
    labels = {
      App = "web-app"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "web-app"
      }
    }
    template {
      metadata {
        labels = {
          App = "web-app"
        }
      }
      spec {
        container {
          image = "buildapp/capstone-part1"
          name  = "web-app"

          port {
            container_port = 9090
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web-app" {
  metadata {
    name = "web-app"
  }
  spec {
    selector = {
      App = kubernetes_deployment.web-app.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30333
      port        = 9090
      target_port = 9090
    }

    type = "NodePort"
  }
}
