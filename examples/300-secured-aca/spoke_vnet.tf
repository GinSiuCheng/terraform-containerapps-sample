# Azapi is leveraged to support Microsoft.App/environments delegation that is not available in current terraform subnet resource (05/02/2023) 
# Combining Azapi type "Microsoft.Network/virtualNetworks/subnets@2022-07-01" with terraform virtual network resource yield unexpected behaviors
# Consequently, entire VNET + Subnets were created via AzAPI instead

resource "azapi_resource" "spoke" {
  type      = "Microsoft.Network/virtualNetworks@2022-07-01"
  name      = "${var.spoke_name}-vnet"
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = [var.spoke_address_space]
      }
      dhcpOptions = {
        dnsServers = [azurerm_firewall.hub.ip_configuration[0].private_ip_address]
      }
    }
  })
  depends_on = [
    azurerm_virtual_network.hub,
    azurerm_firewall.hub
  ]
}

resource "azapi_resource" "spoke_default_subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
  name      = "default"
  parent_id = azapi_resource.spoke.id
  body = jsonencode({
    properties = {
      addressPrefix = "${var.spoke_default_subnet_prefix}"
    }
  })
  depends_on = [azapi_resource.spoke]
}

resource "azapi_resource" "spoke_pe_subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
  name      = "pe-subnet"
  parent_id = azapi_resource.spoke.id
  body = jsonencode({
    properties = {
      addressPrefix                  = "${var.spoke_pe_subnet_prefix}"
      privateEndpointNetworkPolicies = "Disabled"
    }
  })
  depends_on = [
    azapi_resource.spoke,
    azapi_resource.spoke_default_subnet
  ]
}

resource "azapi_resource" "spoke_aca_subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
  name      = "infrastructure-subnet"
  parent_id = azapi_resource.spoke.id
  body = jsonencode({
    properties = {
      networkSecurityGroup = {
        id = "${azurerm_network_security_group.aca.id}"
      }
      routeTable = {
        id = "${azapi_resource.aca_route_table.id}"
      }
      addressPrefix = "${var.spoke_aca_subnet_prefix}"
      delegations = [
        {
          name = "Microsoft.App.environments"
          properties = {
            serviceName = "Microsoft.App/environments"
          }
        }
      ]
    }
  })
  depends_on = [
    azapi_resource.spoke,
    azapi_resource.spoke_default_subnet,
    azapi_resource.spoke_pe_subnet,
    azurerm_network_security_group.aca,
    azapi_resource.aca_route_table
  ]
}