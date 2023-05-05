resource "azurerm_public_ip" "hub_fw" {
  name                = "${var.hub_name}-firewall-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "hub_fw" {
  name                = "${var.hub_name}-fwpolicy"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  dns {
    proxy_enabled = true
    servers       = ["168.63.129.16"]
  }
  insights {
    enabled                            = true
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.logging.id
    retention_in_days                  = 30
  }
}

resource "azurerm_firewall" "hub" {
  name                = "${var.hub_name}-firewall"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  firewall_policy_id  = azurerm_firewall_policy.hub_fw.id
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration {
    name                 = "${var.hub_name}-firewall-ipconfig"
    subnet_id            = azurerm_subnet.hub_fw.id
    public_ip_address_id = azurerm_public_ip.hub_fw.id
  }
}



resource "azurerm_firewall_policy_rule_collection_group" "hub_fw" {
  name               = "${var.hub_name}-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.hub_fw.id
  priority           = 100

  network_rule_collection {
    name     = "aca_rule_collection"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "allow_mcr_frontdoor_monitor"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["MicrosoftContainerRegistry", "AzureFrontDoor.FirstParty", "AzureMonitor"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "allow_ntp"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
    rule {
      name                  = "allow_AAD"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureActiveDirectory"]
      destination_ports     = ["*"]
    }
    rule {
      name                  = "allow443"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }
  }
}