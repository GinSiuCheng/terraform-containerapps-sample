locals {
  landing_zone_name = var.landing_zone.name
  location          = var.landing_zone.location
  address_space     = var.landing_zone.address_space
  subnets           = var.landing_zone.subnets
  tags              = var.landing_zone.tags
  vm_username       = var.vm_username
  vm_password       = var.vm_password
  vm_size           = var.vm_size
  default_subnet_id = length([for subnet in azurerm_subnet.this : subnet.id if subnet.name == "default"]) > 0 ? [for subnet in azurerm_subnet.this : subnet.id if subnet.name == "default"][0] : null
  bastion_subnet_id = length([for subnet in azurerm_subnet.this : subnet.id if subnet.name == "AzureBastionSubnet"]) > 0 ? [for subnet in azurerm_subnet.this : subnet.id if subnet.name == "AzureBastionSubnet"][0] : null
  fw_subnet_id      = length([for subnet in azurerm_subnet.this : subnet.id if subnet.name == "AzureFirewallSubnet"]) > 0 ? [for subnet in azurerm_subnet.this : subnet.id if subnet.name == "AzureFirewallSubnet"][0] : null
}

resource "azurerm_virtual_network" "this" {
  name                = "${local.landing_zone_name}-vnet"
  address_space       = local.address_space
  location            = local.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  count                = length(local.subnets)
  name                 = local.subnets[count.index].name
  address_prefixes     = local.subnets[count.index].address_prefixes
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  depends_on = [
    azurerm_virtual_network.this
  ]
}
