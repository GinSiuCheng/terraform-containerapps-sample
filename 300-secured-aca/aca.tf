# As ACA workload profile is a new preview feature, AzAPI was leverage. 
# These are similar to bicep structurally and provides direct calls to Azure APIs. 
# See: https://registry.terraform.io/providers/Azure/azapi/latest/docs

# Note: dedicated and consumption workload profile is hardcoded below, these should be altered as input variables in future iterations. 
# Similarly ACA app should also be altered to ref. other images via variable ref..
resource "azapi_resource" "aca_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-11-01-preview"
  name      = var.aca_env_name
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  body = jsonencode({
    properties = {
      vnetConfiguration = {
        internal               = true,
        infrastructureSubnetId = "${azapi_resource.spoke_aca_subnet.id}"
      }
      appLogsConfiguration = {
        destination = "log-analytics",
        logAnalyticsConfiguration = {
          customerId = "${azurerm_log_analytics_workspace.logging.workspace_id}",
          sharedKey  = "${azurerm_log_analytics_workspace.logging.primary_shared_key}"
        }
      }
      zoneRedundant = false
      workloadProfiles = [
        {
          name                = "Consumption",
          workloadProfileType = "Consumption"
        },
        {
          "workloadProfileType" : "D4",
          "name" : "Dedicated",
          "minimumCount" : 2,
          "maximumCount" : 4
        }
      ]
    }
  })
  depends_on = [
    azurerm_resource_group.this,
    azapi_resource.spoke,
    azapi_resource.spoke_aca_subnet,
    azapi_resource.aca_route_table,
    azurerm_network_security_group.aca,
    azurerm_firewall_policy_rule_collection_group.hub_fw,
    azurerm_log_analytics_workspace.logging
  ]
}

resource "azapi_resource" "aca" {
  type      = "Microsoft.App/containerApps@2022-11-01-preview"
  name      = "${var.aca_name}"
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  body = jsonencode({
    properties = {
      managedEnvironmentId = "${azapi_resource.aca_environment.id}"
      workloadProfileName  = "Consumption"
      configuration = {
        ingress = {
          external   = false,
          targetPort = 80,
          traffic = [
            {
              weight         = 100,
              latestRevision = true,
              label          = "dev"
            }
          ]
        }
        registries = [
          {
            server   = "${azurerm_container_registry.spoke.login_server}",
            identity = "${azurerm_user_assigned_identity.aca.id}"
          }
        ]
      }
      template = {
        containers = [
          {
            image = "${azurerm_container_registry.spoke.login_server}/azuredocs/containerapps-helloworld:latest",
            name  = "hello-world-acr",
            resources = {
              cpu    = 0.5,
              memory = "1Gi"
            }
            probes = null
          }
        ],
        scale = {
          minReplicas = 2,
          maxReplicas = 10,
          rules       = null
        }
      }
    }
  })
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca.id]
  }
  depends_on = [
    azapi_resource.aca_environment
  ]
}