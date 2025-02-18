variable "resource_group_name" {
  type        = string
  description = "Name of the resource group provided."
}

variable "prefix" {
  type        = string
  description = "Prefix to be used for all resources."
}

variable "default_tags" {
  type = object({})
  default = {
    environment = "dev"
    project     = "learning"
  }
}

variable "aks_vnet_definition" {
  type = object({
    name          = string
    address_space = string
    subnets = list(object({
      name          = string
      address_space = string
    }))
  })

  default = {
    name          = "aks-vnet"
    address_space = "10.64.0.0/16"
    subnets = [
      {
        name          = "ingress"
        address_space = "10.64.4.0/24"
      },
      {
        name          = "nodes"
        address_space = "10.64.0.0/22"
      }
    ]
  }

  description = "AKS cluster network definition"
}

variable "attach_keyvault_to_aks" {
  type    = bool
  default = false
}

# AKS cluster definition
variable "aks_cluster_definition" {
  type = object({
    sku_tier               = string
    loadbalancer_sku       = string
    assign_acr             = bool
    kubernetes_version     = string
    aks_sku_tier           = string
    rbac_auth_nabled       = bool
    enable_host_encryption = bool
    masters = object({
      count   = number
      vm_size = string
    }),
    workers = object({
      count   = number
      vm_size = string
    })
    cni_plugin            = string
    network_policy_engine = string
    addons = map(object({
      external_url    = optional(string)
      selfsigned_cert = optional(bool)
    }))
    create_cluster_log_analytics_workspace = bool
  })

  default = {
    sku_tier               = "Free"
    loadbalancer_sku       = "standard"
    assign_acr             = false
    kubernetes_version     = "1.30"
    aks_sku_tier           = "Standard"
    rbac_auth_nabled       = true
    enable_host_encryption = false

    masters = {
      count   = 2
      vm_size = "Standard_D2s_v3"
    }

    workers = {
      count   = 2
      vm_size = "Standard_D2s_v3"
    }

    cni_plugin            = "azure"
    network_policy_engine = "azure"

    addons = {
      "argocd" = {
        external_url    = "dev-argocd.example.com",
        selfsigned_cert = true
      }
    }

    create_cluster_log_analytics_workspace = false
  }
}

variable "flux_chart_version" {
  type    = string
  default = "2.12.4"
}

variable "argocd_chart_version" {
  type    = string
  default = "7.6.10"
}
