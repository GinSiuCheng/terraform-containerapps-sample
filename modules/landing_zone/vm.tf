resource "azurerm_network_interface" "vm_nic" {
  count               = var.create_default_vm > 0 ? 1 : 0
  name                = "${local.landing_zone_name}-vm-nic"
  location            = local.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${local.landing_zone_name}-ipconfig1"
    subnet_id                     = local.default_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
  depends_on = [
    azurerm_subnet.this
  ]
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.create_default_vm > 0 ? 1 : 0
  name                            = "${local.landing_zone_name}-vm"
  location                        = local.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.vm_nic[0].id]
  size                            = local.vm_size
  admin_username                  = local.vm_username
  admin_password                  = local.vm_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${local.landing_zone_name}-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = local.tags
  depends_on = [
    azurerm_network_interface.vm_nic
  ]
}