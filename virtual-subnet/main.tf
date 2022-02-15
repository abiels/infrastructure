resource "azurerm_subnet" "subnet" {
  #for_each             = var.subnets
  name                 = format("%s-%s-subnet-%s-%s", var.prefix, terraform.workspace, var.name, random_integer.subnet.id)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.addr_range]
  service_endpoints    = var.service_endpoints
}

resource "random_integer" "subnet" {
  min = 001
  max = 500
}
