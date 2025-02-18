##################################################################
# ROLE ASSIGNMENT - KUBELET USER ASSIGNED IDENTITY WITH ACR
##################################################################
resource "azurerm_role_assignment" "kubelet_acr" {
  principal_id                     = module.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.default[0].id
  skip_service_principal_aad_check = true
}