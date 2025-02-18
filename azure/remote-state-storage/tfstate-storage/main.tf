##################################################################
# Existing resource group
##################################################################
data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

##################################################################
# Random integer
##################################################################
resource "random_integer" "storage" {
  min = 1000
  max = 9999
}

##################################################################
# Storage account
##################################################################
resource "azurerm_storage_account" "this" {
  name                     = "${lower(var.prefix)}tfacc${random_integer.storage.result}"
  resource_group_name      = data.azurerm_resource_group.default.name
  location                 = data.azurerm_resource_group.default.location
  account_tier             = try(var.storage_account_tier, "Standard")
  account_replication_type = try(var.storage_account_replication_type, "LRS")
  account_kind             = try(var.storage_account_sku, "StorageV2")
  min_tls_version          = "TLS1_2"

  https_traffic_only_enabled        = true  # HTTPS traffic only: Enabled
  shared_access_key_enabled         = false # Shared access key: Disabled
  default_to_oauth_authentication   = true  # Default to OAuth authentication: Enabled
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 90
    last_access_time_enabled      = true

    delete_retention_policy {
      days = try(var.remote_state_delete_retention_days, 30)
    }

    container_delete_retention_policy {
      days = try(var.remote_state_delete_retention_days, 30)
    }
  }

  sas_policy {
    expiration_period = "00.02:00:00" # 2 hours
    expiration_action = "Log"
  }

  timeouts {
    create = "5m"
    read   = "5m"
  }

  tags = merge(var.default_tags, {
    environment = var.prefix
  })
}

##################################################################
# Storage account container
##################################################################
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
