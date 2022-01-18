terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "=2.92.0"
        }
    }
    backend "azurerm" {
        resource_group_name  = "abiels_tfstate"
        storage_account_name = "tfstateubc1m"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
}

module "resource-groups" {
    source = "./resource-groups"
}

module "container-registries" {
    source = "./container-registries"
}