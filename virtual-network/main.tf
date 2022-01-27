resource "azurerm_network_security_group" "web" {
  name                = format("%s-%s-sg-web-%s", var.prefix, terraform.workspace, random_integer.vnet.id)
  location            = var.location
  resource_group_name = var.resource_group_name
}
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.web.id
}


resource "azurerm_virtual_network" "vnet" {
  name                = format("%s-%s-vnet-%s", var.prefix, terraform.workspace, random_integer.vnet.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = format("%s-%s-subnet-app-%s", var.prefix, terraform.workspace, random_integer.vnet.id)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# resource "azurerm_subnet" "backend" {
#   name                = format("%s-%s-subnet-backend-%s", var.prefix, terraform.workspace, random_integer.subnet.id)
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

resource "azurerm_public_ip" "public_ip" {
  name                = format("%s-%s-subnet-public-%s", var.prefix, terraform.workspace, random_integer.vnet.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "app-gw" {
  name                = format("%s-%s-app-gw-%s", var.prefix, terraform.workspace, random_integer.vnet.id)
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = format("%s-%s-app-gw-ipconfig-%s", var.prefix, terraform.workspace, random_integer.vnet.id)
    subnet_id = azurerm_subnet.app.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = var.backend_http_patch
    port                  = var.backend_http_port
    protocol              = var.backand_http_protocol
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}


resource "random_integer" "vnet" {
  min = 001
  max = 500
}
