resource "azurerm_route_table" "aca" {
  name                = "aca-routes"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "internet" {
  name                   = "internet"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.aca.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}