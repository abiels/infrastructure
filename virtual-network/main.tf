
resource "azurerm_virtual_network" "main" {
  name                = format("%s-%s-vnet-%s", var.prefix, terraform.workspace, var.virtual_network_name)
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_space]
}
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = format("%s-%s-subnet-%s-%s", var.prefix, terraform.workspace, each.value.name, random_integer.subnet.id)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.addr_range]
  service_endpoints    = each.value.service_endpoints
}

resource "random_integer" "subnet" {
  min = 001
  max = 500
}
