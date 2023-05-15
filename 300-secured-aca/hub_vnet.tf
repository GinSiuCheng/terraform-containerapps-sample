resource "azurerm_virtual_network" "hub" {
  name                = "${var.hub_name}-vnet"
  address_space       = [var.hub_address_space]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "hub_fw" {
  name                 = "AzureFirewallSubnet"
  address_prefixes     = [var.hub_fw_subnet_prefix]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
}

resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  address_prefixes     = [var.hub_bastion_subnet_prefix]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
}

resource "azurerm_subnet" "hub_default" {
  name                 = "default"
  address_prefixes     = [var.hub_default_subnet_prefix]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
}

resource "azurerm_virtual_network_dns_servers" "hub" {
  virtual_network_id = azurerm_virtual_network.hub.id
  dns_servers        = [azurerm_firewall.hub.ip_configuration[0].private_ip_address]
}

resource "azurerm_virtual_network_peering" "hub_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azapi_resource.spoke.id
}