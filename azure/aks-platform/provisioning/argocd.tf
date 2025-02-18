##################################################################
# ARGO CD - Namespace
##################################################################
resource "kubernetes_namespace" "argocd_namespace" {
  count = contains(keys(var.aks_cluster_definition.addons), "argocd") ? 1 : 0 # Install only if user has specified argocd addon
  metadata {
    name = "argocd"
  }

  depends_on = [module.aks]
}


##################################################################
# ARGO CD - Helm
##################################################################
# https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml
resource "helm_release" "argocd" {
  count       = contains(keys(var.aks_cluster_definition.addons), "argocd") ? 1 : 0 # Install only if user has specified argocd addon
  name        = "argo-cd"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  version     = try(var.argocd_chart_version, "5.45.0")
  description = "A Helm chart to install the ArgoCD"
  namespace   = try(kubernetes_namespace.argocd_namespace[0].metadata[0].name, "argocd")

  depends_on = [kubernetes_namespace.argocd_namespace]
}

##################################################################
# ARGO CD - TLS self signed certificate private key
##################################################################
resource "tls_private_key" "argocd_tls_key" {
  count     = contains(keys(var.aks_cluster_definition.addons), "argocd") && try(var.aks_cluster_definition.addons["argocd"].selfsigned_cert) ? 1 : 0 # create self signed cert private key only if user selfsigned_cert = true
  algorithm = "RSA"
  rsa_bits  = 4096
}

##################################################################
# ARGO CD - TLS  self signed certificate
##################################################################
resource "tls_self_signed_cert" "argocd_tls_cert" {
  count                 = contains(keys(var.aks_cluster_definition.addons), "argocd") && try(var.aks_cluster_definition.addons["argocd"].selfsigned_cert) ? 1 : 0 # create self signed cert only if user selfsigned_cert = true
  private_key_pem       = tls_private_key.argocd_tls_key[0].private_key_pem
  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [
    var.aks_cluster_definition.addons["argocd"].external_url,
    "www.${var.aks_cluster_definition.addons["argocd"].external_url}"
  ]

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }
}

##################################################################
# ARGO CD - Kubernetes TLS secret
##################################################################
resource "kubernetes_secret" "argocd_tls" {
  metadata {
    name      = "argocd-tls-secret"
    namespace = try(kubernetes_namespace.argocd_namespace[0].metadata[0].name, "argocd")
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.argocd_tls_cert[0].cert_pem
    "tls.key" = tls_private_key.argocd_tls_key[0].private_key_pem # must be .PEM encoded
  }

  depends_on = [tls_self_signed_cert.argocd_tls_cert]
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = try(kubernetes_secret.argocd_tls.metadata[0].namespace, "argocd")

    annotations = {
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = true
      "nginx.ingress.kubernetes.io/ssl-passthrough"    = true
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
    }
  }


  spec {
    ingress_class_name = "webapprouting.kubernetes.azure.com"

    tls {
      hosts       = [var.aks_cluster_definition.addons["argocd"].external_url]
      secret_name = kubernetes_secret.argocd_tls.metadata[0].name
    }

    rule {
      host = var.aks_cluster_definition.addons["argocd"].external_url

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argo-cd-argocd-server"
              port {
                name = "https"
              }
            }
          }
        }
      }
    }
  }
}
