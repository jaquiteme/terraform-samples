##################################################################
# GENERATE RANDOM ID FOR KEY VAULT
##################################################################
resource "random_id" "key_vault" {
  byte_length = 1
}

##################################################################
# AZURE CLIENT DATA
##################################################################
data "azurerm_client_config" "current" {}


##################################################################
# AZURE KEY VAULT
##################################################################
resource "azurerm_key_vault" "default" {
  count                      = var.attach_keyvault_to_aks ? 1 : 0
  name                       = "${var.prefix}akskeyvault${random_id.key_vault.dec}"
  location                   = data.azurerm_resource_group.default.location
  resource_group_name        = data.azurerm_resource_group.default.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.default.principal_id

    certificate_permissions = [
      "Get", "List", "Create", "Update", "ListIssuers", "GetIssuers", "Purge"
    ]

    key_permissions = [
      "Get", "List", "Encrypt", "Create", "Decrypt", "Import", "Verify", "Update"
    ]

    secret_permissions = [
      "Get", "List", "Set"
    ]

    storage_permissions = [
      "Get", "List", "Update", "Set"
    ]
  }

  tags = merge(var.default_tags)
}
