resource "azurerm_log_analytics_workspace" "logging" {
  name                = var.la_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "logging" {
  name                     = var.sa_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_network_watcher" "aca" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "NetworkWatcher_eastus"
}

resource "azurerm_network_watcher_flow_log" "aca" {
  network_watcher_name = azurerm_network_watcher.aca.name
  resource_group_name  = azurerm_network_watcher.aca.resource_group_name
  name                 = "aca-nsg-log"

  network_security_group_id = azurerm_network_security_group.aca.id
  storage_account_id        = azurerm_storage_account.logging.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.logging.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.logging.location
    workspace_resource_id = azurerm_log_analytics_workspace.logging.id
    interval_in_minutes   = 10
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = "fw-diagnostics"
  target_resource_id             = azurerm_firewall.hub.id
  storage_account_id             = azurerm_storage_account.logging.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.logging.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AZFWApplicationRule"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWApplicationRuleAggregation"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWDnsQuery"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWFatFlow"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWFlowTrace"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWFqdnResolveFailure"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWIdpsSignature"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWNatRule"

    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWNatRuleAggregation"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWNetworkRule"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWNetworkRuleAggregation"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  enabled_log {
    category = "AZFWThreatIntel"
    retention_policy {
      days    = 30
      enabled = true
    }
  }
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
    }
  }
}