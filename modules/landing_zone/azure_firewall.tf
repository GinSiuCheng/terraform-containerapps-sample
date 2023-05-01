resource "azurerm_public_ip" "firewall_public_ip" {
  count               = var.create_firewall > 0 ? 1 : 0
  name                = "${local.landing_zone_name}-firewall-pip"
  location            = local.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall" "firewall" {
  count               = var.create_firewall > 0 ? 1 : 0
  name                = "${local.landing_zone_name}-firewall"
  location            = local.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "${local.landing_zone_name}-firewall-ipconfig"
    subnet_id            = local.fw_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip[0].id
  }
  tags = local.tags
  
  depends_on = [
    azurerm_virtual_network.this,
    azurerm_subnet.this
  ]
}
