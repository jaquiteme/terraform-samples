##################################################################
# Existing resource group
##################################################################
data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

##################################################################
# VNET
##################################################################
resource "azurerm_virtual_network" "default" {
  name = "tf-example-vnet"
  resource_group_name = data.azurerm_resource_group.default.name
  location = data.azurerm_resource_group.default.location
  address_space = [ "172.16.0.0/16" ]
  
  subnet {
    name = "subnet1"
    address_prefixes = ["172.16.0.0/24"]
  }

  tags = {
    environment = "dev"
  }
}