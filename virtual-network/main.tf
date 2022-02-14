resource "azurerm_virtual_network" "vnet" {
  name                = format("%s-%s-vnet-%s", var.prefix, terraform.workspace, random_integer.vnet.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_space]
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = format("%s-%s-subnet-%s-%s", var.prefix, terraform.workspace, each.value.name, random_integer.vnet.id)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.addr_range]
  service_endpoints    = each.value.service_endpoints
}


resource "random_integer" "vnet" {
  min = 001
  max = 500
}
