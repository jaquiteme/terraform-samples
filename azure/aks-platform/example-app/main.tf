
##################################################################
# FLUX CD - Git Repo
##################################################################
resource "kubernetes_manifest" "flux_git_repo" {
  manifest = {
    "apiVersion" = "source.toolkit.fluxcd.io/v1"
    "kind"       = "GitRepository"
    "metadata" = {
      "name"      = "taco-fleet"
      "namespace" = "flux-system"
    }

    spec = {
      interval = "1m"

      ref = {
        branch = "main"
      }

      url = "https://github.com/ned1313/taco-fleet"
    }
  }
}

##################################################################
# FLUX CD - APP Kustomization Infra
##################################################################
resource "kubernetes_manifest" "flux_kustomization_infra" {
  manifest = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "taco-fleet-infra"
      "namespace" = "flux-system"
    }

    spec = {
      interval = "30m0s"
      path = "./infrastructure"
      prune = true
      retryInterval = "2m0s"

      sourceRef = {
        kind = "GitRepository"
        name = "taco-fleet"
      }

      targetNamespace = "default"
      timeout = "3m0s"
      wait = true
    }
  }
}

##################################################################
# FLUX CD - APP Kustomization Infra
##################################################################
resource "kubernetes_manifest" "flux_kustomization_app" {
  manifest = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "taco-fleet-app"
      "namespace" = "flux-system"
    }

    spec = {
      interval = "30m0s"
      path = "./dotnet-lb"
      prune = true
      retryInterval = "2m0s"

      sourceRef = {
        kind = "GitRepository"
        name = "taco-fleet"
      }

      targetNamespace = "default"
      timeout = "3m0s"
      wait = true
    }
  }
}