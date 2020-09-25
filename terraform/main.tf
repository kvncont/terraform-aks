terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  version = "=2.24.0"
  features {}
}

resource azurerm_resource_group rg_aks {
  name     = var.rg_aks_name
  location = var.rg_aks_location
  tags     = var.tags
}

resource azurerm_network_security_group nsg_aks {
  name                = var.nsg_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  tags                = var.tags
}

resource azurerm_virtual_network vnet_aks {
  name                = var.vnet_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  address_space       = var.vnet_aks_address_space
  dns_servers         = var.vnet_aks_dns_server
  tags                = var.tags
}

resource azurerm_subnet subnet_aks {
  name                 = var.subnet_aks_name
  resource_group_name  = azurerm_resource_group.rg_aks.name
  virtual_network_name = var.vnet_aks_name
  address_prefixes     = var.subnet_aks_address

  depends_on = [
    azurerm_virtual_network.vnet_aks
  ]
}

resource azurerm_log_analytics_workspace law_aks {
  name                = var.law_aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  sku                 = "PerGB2018"
  tags                = var.tags
}

# resource azurerm_log_analytics_solution las_aks {
#   solution_name         = "ContainerInsights"
#   location              = azurerm_resource_group.rg_aks.location
#   resource_group_name   = azurerm_resource_group.rg_aks.name
#   workspace_resource_id = azurerm_log_analytics_workspace.law_aks.id
#   workspace_name        = azurerm_log_analytics_workspace.law_aks.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGalleryContainerInsights"
#   }

#   depends_on = [
#     azurerm_log_analytics_workspace.law_aks
#   ]
# }

resource azurerm_kubernetes_cluster aks {
  name                = var.aks_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  dns_prefix          = "${var.aks_name}-dns"
  kubernetes_version  = var.aks_kubernetes_version

  default_node_pool {
    name                 = var.aks_default_node_pool_name
    orchestrator_version = var.aks_kubernetes_version
    vm_size              = var.aks_vm_size
    enable_auto_scaling  = true
    type                 = "VirtualMachineScaleSets"
    # availability_zones   = ["1", "2"]
    # sku_tier             = Paid
    vnet_subnet_id       = azurerm_subnet.subnet_aks.id

    node_count           = var.aks_node_count_default
    max_count            = var.aks_node_max_count
    min_count            = var.aks_node_min_count
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "Standard"
    # service_cidr       = "10.0.0.0/16"
    # dns_service_ip     = "10.0.0.10"
    # docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count
    ]
  }

  depends_on = [
    azurerm_subnet.subnet_aks
  ]

  tags = var.tags
}

# resource azurerm_monitor_diagnostic_setting ds_aks {
#   name                       = var.diagnostic_setting_name
#   target_source_id           = azurerm_kubernetes_cluster.aks.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law_aks.id

#   dynamic log {
#     for_each = var.diagnostic_setting_log_categories
#     content {
#       category = log.value
#       enabled  = true
#     }
#   }

#   depends_on = [
#     azurerm_log_analytics_workspace.law_aks,
#     azurerm_kubernetes_cluster.aks
#   ]

#   tags = var.tags
# }