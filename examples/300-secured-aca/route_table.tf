resource "azapi_resource" "aca_route_table" {
  type      = "Microsoft.Network/routeTables@2022-09-01"
  name      = "${var.aca_name}-routes"
  parent_id = azurerm_resource_group.this.id
  location  = azurerm_resource_group.this.location
}

resource "azapi_resource" "aca_internet_route" {
  type      = "Microsoft.Network/routeTables/routes@2022-09-01"
  name      = "internet"
  parent_id = azapi_resource.aca_route_table.id
  body = jsonencode({
    properties = {
      nextHopType      = "VirtualAppliance",
      nextHopIpAddress = "${azurerm_firewall.hub.ip_configuration[0].private_ip_address}",
      addressPrefix    = "0.0.0.0/0"
    }
  })
}

resource "azurerm_virtual_network_peering" "spoke_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azapi_resource.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}