resource "azurerm_public_ip" "hub_bastion_ip" {
  name                = "${var.hub_name}-bastion-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.hub_name}-bastion"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                 = "${var.hub_name}-bastion-ipconfig"
    public_ip_address_id = azurerm_public_ip.hub_bastion_ip.id
    subnet_id            = azurerm_subnet.hub_bastion.id
  }
}