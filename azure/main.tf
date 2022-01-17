terraform {
required_providers {
    azurerm = {
    source  = "hashicorp/azurerm"
    version = "=2.92.0"
    }
}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
features {}
}

module "resource-groups" {
    source = "./resource-groups"
}


# module "virtual-networks" {
#   source = "./virtual-networks"
#   resource_group_name = module.resource_group.skillup.name
#   resource_group_location = module.resource_group.skillup.location
# }