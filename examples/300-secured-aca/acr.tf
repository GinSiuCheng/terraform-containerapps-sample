data "http" "terraform_runner_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_container_registry" "spoke" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Premium"
  admin_enabled       = false
  network_rule_set {
    default_action = "Deny"
    ip_rule {
      action   = "Allow"
      ip_range = var.my_ip
    }
    ip_rule {
      action   = "Allow"
      ip_range = "${chomp(data.http.terraform_runner_ip.response_body)}/32"
    }
  }
}

resource "azurerm_private_endpoint" "acr" {
  name                = "${var.acr_name}_private_endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azapi_resource.spoke_pe_subnet.id

  private_dns_zone_group {
    name                 = "${var.acr_name}_dns_zone_group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }

  private_service_connection {
    name                           = "${var.acr_name}_connection"
    private_connection_resource_id = azurerm_container_registry.spoke.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  depends_on = [azapi_resource.spoke_pe_subnet]
}

resource "null_resource" "sample_image" {
  provisioner "local-exec" {
    command = <<-EOT
      az acr login -n "${azurerm_container_registry.spoke.name}"
      docker pull "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      docker tag "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" "${azurerm_container_registry.spoke.name}.azurecr.io/azuredocs/containerapps-helloworld:latest"
      docker push "${azurerm_container_registry.spoke.name}.azurecr.io/azuredocs/containerapps-helloworld:latest"
    EOT
  }
  depends_on = [ azurerm_container_registry.spoke ]
}