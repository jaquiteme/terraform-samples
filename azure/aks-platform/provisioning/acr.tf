##################################################################
# GENERATE RANDOM ID FOR ACR
##################################################################
resource "random_id" "acr" {
  byte_length = 2
}

##################################################################
# AZURE CONTAINER REGISTRY
##################################################################
resource "azurerm_container_registry" "default" {
  count               = var.aks_cluster_definition.assign_acr ? 1 : 0
  name                = "${var.prefix}aksacr${random_id.acr.dec}"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name
  sku                 = "Basic"
  admin_enabled       = false

  tags = merge(var.default_tags)
}
