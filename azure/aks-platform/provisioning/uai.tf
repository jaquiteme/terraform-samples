##################################################################
# AZURE MANAGED IDENTITY - USER ASSIGNED IDENTITY
##################################################################
resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.prefix}aksuai"
  location            = data.azurerm_resource_group.default.location
  resource_group_name = data.azurerm_resource_group.default.name

  tags = merge(var.default_tags)
}
