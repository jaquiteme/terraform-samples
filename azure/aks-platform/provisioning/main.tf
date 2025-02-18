##################################################################
# Existing resource group
##################################################################
data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}


##################################################################
# AKS cluster VNET : Module
##################################################################
module "aks_vnet" {
  source              = "Azure/subnets/azurerm"
  version             = "1.0.0"
  resource_group_name = data.azurerm_resource_group.default.name

  subnets = {
    aks = {
      address_prefixes = ["10.64.0.0/16"]
    }
  }

  virtual_network_address_space = try([var.aks_vnet_definition.address_space], [])
  virtual_network_location      = data.azurerm_resource_group.default.location
  virtual_network_name          = "${try(var.prefix, "dev")}-${var.aks_vnet_definition.name}"
  virtual_network_tags          = merge(var.default_tags)
}

##################################################################
# AKS log analytics workspace
##################################################################
resource "azurerm_log_analytics_workspace" "default" {
  count               = var.aks_cluster_definition.create_cluster_log_analytics_workspace ? 1 : 0
  name                = "${var.prefix}-aks-default-log-analytics-workspace"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

##################################################################
# AKS cluster: Module
##################################################################
module "aks" {
  source  = "Azure/aks/azurerm"
  version = "9.2.0"

  resource_group_name             = data.azurerm_resource_group.default.name
  location                        = data.azurerm_resource_group.default.location
  automatic_channel_upgrade       = "node-image"
  node_os_channel_upgrade         = "NodeImage"
  log_analytics_workspace_enabled = try(var.aks_cluster_definition.create_cluster_log_analytics_workspace, false)
  log_analytics_workspace = {
    id   = azurerm_log_analytics_workspace.default[0].id
    name = azurerm_log_analytics_workspace.default[0].name
  } # Cluster log analytics workspace

  sku_tier                = try(var.aks_cluster_definition.aks_sku_tier, "Standard")
  private_cluster_enabled = false
  enable_host_encryption  = try(var.aks_cluster_definition.enable_host_encryption, false) # Feature must be enable at subscription level
  prefix                  = var.prefix

  rbac_aad                          = (var.aks_cluster_definition.rbac_auth_nabled ? false : true)
  role_based_access_control_enabled = try(var.aks_cluster_definition.rbac_auth_nabled, false) # Kubernetes RBAC
  vnet_subnet_id                    = lookup(module.aks_vnet.vnet_subnets_name_id, "aks")

  load_balancer_sku = try(var.aks_cluster_definition.loadbalancer_sku, "basic")

  agents_pool_name = "masters"
  agents_count     = try(var.aks_cluster_definition.masters.count, 1)
  agents_size      = try(var.aks_cluster_definition.masters.vm_size, "Standard_D2s_v3")
  node_pools = {
    "workers" = {
      name       = "workers"
      node_count = try(var.aks_cluster_definition.workers.count, 1)
      vm_size    = try(var.aks_cluster_definition.workers.vm_size, "Standard_D2s_v3")
      tags = merge(var.default_tags, {
        node_type = "worker"
      })
    }
  }

  image_cleaner_enabled = true

  identity_type = "UserAssigned"
  # List of managed identies to be assigned to this cluster
  identity_ids = [
    azurerm_user_assigned_identity.default.id
  ]

  web_app_routing = {
    dns_zone_id = null # TODO : allow private dns
  }

  network_plugin = try(var.aks_cluster_definition.cni_plugin, "azure")            # CNI to use
  network_policy = try(var.aks_cluster_definition.network_policy_engine, "azure") # network policy engine to use

  # monitor_metrics = {}

  agents_tags = merge(var.default_tags, {
    node_type = "master"
  })

  depends_on = [module.aks_vnet]
}
