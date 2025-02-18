##################################################################
# FLUX CD - Namespace
##################################################################
resource "kubernetes_namespace" "flux_system" {
  count = contains(keys(var.aks_cluster_definition.addons), "flux") ? 1 : 0 # Install only user has specified flux addon
  metadata {
    name = "flux-system"
  }

  depends_on = [module.aks]
}

##################################################################
# FLUX CD - Helm
##################################################################
resource "helm_release" "flux2" {
  name       = "flux2"
  count      = contains(keys(var.aks_cluster_definition.addons), "flux") ? 1 : 0 # Install only user has specified flux addon
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = var.flux_chart_version
  namespace  = try(kubernetes_namespace.flux_system[0].metadata[0].name, "flux-system")

  depends_on = [kubernetes_namespace.flux_system]
}
