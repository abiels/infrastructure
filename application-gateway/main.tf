locals {
  frontend_port_name             = "appgw-${var.app_gw_name}-feport"
  frontend_ip_configuration_name = "appgw-${var.app_gw_name}-feip"
  gateway_ip_configuration_name  = "appgw-${var.app_gw_name}-gwipc"
  http_listener_name             = "appgw-${var.app_gw_name}-http_listener" # var.http_listener_name
}

resource "azurerm_public_ip" "public_ip" {
  name                = format("%s-%s-public-ip-%s", var.prefix, terraform.workspace, var.public_ip_number)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}
resource "azurerm_application_gateway" "network" {
  name                = format("%s-%s-app-gw-%s-%s", var.prefix, terraform.workspace, var.app_gw_name, var.app_gw_number)
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku_name
    tier     = var.tier_name
    capacity = var.sku_capacity
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = data.azurerm_subnet.subnet.id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      path                                = backend_http_settings.value.path
      port                                = backend_http_settings.value.port
      probe_name                          = backend_http_settings.value.probe_name
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
    }
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    host_names                     = []
    name                           = local.http_listener_name
    protocol                       = "Http"
    require_sni                    = false
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rule
    content {
      http_listener_name = request_routing_rule.value.http_listener_name
      name               = request_routing_rule.value.name
      rule_type          = request_routing_rule.value.rule_type
      url_path_map_name  = request_routing_rule.value.url_path_map_name
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name  = url_path_map.value.default_backend_http_settings_name
      
      dynamic "path_rule" {
        for_each = lookup(url_path_map.value, "path_rules")
        content {
          name                        = path_rule.value.name
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          paths                       = flatten(path_rule.value.paths)
        }
      }
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name  = backend_address_pool.value.name
      fqdns = backend_address_pool.value.fqdns
    }
  }

  probe {
    interval                                  = 30
    minimum_servers                           = 0
    name                                      = "http_80"
    path                                      = "/"
    pick_host_name_from_backend_http_settings = true
    port                                      = "80"
    protocol                                  = "Http"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      status_code = [
        "200-399",
      ]
    }
  }
}

resource "random_integer" "public_ip" {
  min = 001
  max = 500
}
resource "random_integer" "app-gw" {
  min = 001
  max = 500
}
