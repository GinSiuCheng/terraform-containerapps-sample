resource "azurerm_network_interface" "spoke_vm_nic" {
  name                = "${var.spoke_name}-vm-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "${var.spoke_name}-ipconfig1"
    subnet_id                     = azapi_resource.spoke_default_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azapi_resource.spoke,
    azapi_resource.spoke_default_subnet
  ]
}

resource "azurerm_linux_virtual_machine" "spoke_vm" {
  name                            = "${var.spoke_name}-vm"
  location                        = azurerm_resource_group.this.location
  resource_group_name             = azurerm_resource_group.this.name
  network_interface_ids           = [azurerm_network_interface.spoke_vm_nic.id]
  size                            = var.vm_size
  admin_username                  = var.vm_username
  admin_password                  = var.vm_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.spoke_name}-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_network_interface" "hub_vm_nic" {
  name                = "${var.hub_name}-vm-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "${var.hub_name}-ipconfig1"
    subnet_id                     = azurerm_subnet.hub_default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "hub_vm" {
  name                            = "${var.hub_name}-vm"
  location                        = azurerm_resource_group.this.location
  resource_group_name             = azurerm_resource_group.this.name
  network_interface_ids           = [azurerm_network_interface.hub_vm_nic.id]
  size                            = var.vm_size
  admin_username                  = var.vm_username
  admin_password                  = var.vm_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.hub_name}-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}