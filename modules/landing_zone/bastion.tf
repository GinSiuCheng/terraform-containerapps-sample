resource "azurerm_public_ip" "bastion_public_ip" {
  count               = var.create_bastion > 0 ? 1 : 0
  name                = "${local.landing_zone_name}-bastion-pip"
  location            = local.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.create_bastion > 0 ? 1 : 0
  name                = "${local.landing_zone_name}-bastion"
  location            = local.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                 = "${local.landing_zone_name}-bastion-ipconfig"
    public_ip_address_id = azurerm_public_ip.bastion_public_ip[0].id
    subnet_id            = local.bastion_subnet_id
  }
  tags = local.tags
  depends_on = [
    azurerm_virtual_network.this,
    azurerm_subnet.this
  ]
}