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