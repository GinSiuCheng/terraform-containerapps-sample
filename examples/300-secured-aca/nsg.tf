resource "azurerm_network_security_group" "aca" {
  name                = "my-aca-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "allow_azuremonitor" {
  name                        = "AllowAzMonitor"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureMonitor"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "allow_mcr" {
  name                        = "AllowMcr"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "MicrosoftContainerRegistry"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "allow_frontdoor" {
  name                        = "AllowFrontdoor"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureFrontDoor.FirstParty"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "allow_ntp" {
  name                        = "AllowNTP"
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "123"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "allow_acr" {
  name                        = "AllowACR"
  priority                    = 140
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureContainerRegistry"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}


resource "azurerm_network_security_rule" "allow_acacontrol" {
  name                        = "AllowACA"
  priority                    = 150
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["5671", "5672"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "allow_aad" {
  name                        = "AllowAAD"
  priority                    = 160
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "dns_udp_outbound" {
  name                        = "DnsUdpOutbound"
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = azurerm_firewall.hub.ip_configuration[0].private_ip_address
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "dns_tcp_outbound" {
  name                        = "DNSTcpOutbound"
  priority                    = 4010
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = azurerm_firewall.hub.ip_configuration[0].private_ip_address
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "intravnet_outbound" {
  name                        = "AllowIntravnetOutbound"
  priority                    = 4020
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "deny_azuredns" {
  name                        = "DenyAzuredns"
  priority                    = 4030
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzurePlatformDNS"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}

resource "azurerm_network_security_rule" "deny_all" {
  name                        = "DenyAll"
  priority                    = 4040
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.aca.name
}