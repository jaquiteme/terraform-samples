provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  storage_use_azuread = true # As Share Access Key will be disabled
}

provider "random" {}

provider "helm" {
  kubernetes {
    host                   = "https://${module.aks.cluster_fqdn}"
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${module.aks.cluster_fqdn}"
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

provider "tls" {}
