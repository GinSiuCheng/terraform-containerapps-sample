resource "azurerm_user_assigned_identity" "aca" {
  name                = "aca-identity"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "acr" {
  scope                = azurerm_container_registry.spoke.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca.principal_id
}