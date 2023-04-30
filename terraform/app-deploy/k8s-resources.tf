provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_ingress_v1" "package_ingress" {
  metadata {
    namespace = var.k8s_namespace
    name      = "${var.k8s_deploy_name}-app"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx-public"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
      "nginx.ingress.kubernetes.io/cors-allow-headers" = "X-Forwarded-For"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = true
      "nginx.ingress.kubernetes.io/service-upstream"   = true
    }
  }

  spec {
    rule {
      host = "${var.k8s_deploy_name}.${var.k8s_deploy_domain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "${var.k8s_deploy_name}-app"
              port {
                number = 4000
              }
            }
          }
        }
      }
    }

    tls {
      hosts = ["${var.k8s_deploy_name}.${var.k8s_deploy_domain}"]
    }
  }
}

resource "kubernetes_deployment" "demo_app" {
  metadata {
    namespace = var.k8s_namespace
    name      = "${var.k8s_deploy_name}-app"
    labels = {
      "app.kubernetes.io/name"       = "${var.k8s_deploy_name}-app",
      "app.kubernetes.io/instance"   = "${var.k8s_deploy_name}-app",
      "app.kubernetes.io/managed-by" = "${var.k8s_deploy_name}-app"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${var.k8s_deploy_name}-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.k8s_deploy_name}-app"
        }
      }
      spec {
        container {
          image             = "pricecs/p1-protect-demo"
          name              = "${var.k8s_deploy_name}-app"
          image_pull_policy = "Always"

          env {
            # PingOne EnvID
            name  = "ENVID"
            value = module.environment.environment_id
          }
          env {
            # P1 OIDC Client ID
            name  = "OIDCCLIENTID"
            value = pingone_application.app_logon.oidc_options[0].client_id
          }
          env {
            # P1 Worker App ID
            name  = "WORKERID"
            value = pingone_application.dv_worker_app.oidc_options[0].client_id
          }
          env {
            # P1 Worker App Secret
            name  = "WORKERSECRET"
            value = pingone_application.dv_worker_app.oidc_options[0].client_secret
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "demo_app" {
  metadata {
    namespace = var.k8s_namespace
    name      = "${var.k8s_deploy_name}-app"
  }
  spec {
    selector = {
      app = "${var.k8s_deploy_name}-app"
    }
    session_affinity = "ClientIP"
    port {
      port        = var.app_port
      target_port = var.app_port
    }

    type = "ClusterIP"
  }
}