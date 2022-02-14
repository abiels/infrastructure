terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "abiels_tfstate"
    storage_account_name = "tfstateih0w1"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

module "resource-groups" {
  source              = "./resource-groups"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "virtual-network" {
  source              = "./virtual-network"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
}

module "postgresql_development" {
  source = "./postgresql"
  name   = "development"
  sku    = "B_Gen5_1"
  databases = {
    dev-db1 = { name = "dev-db1",
    charset = "UTF8",
    collation = "English_United States.1252" },
    dev-db2 = { name = "dev-db2",
    charset = "UTF8",
    collation = "English_United States.1252" }
  }
  backup                  = false
  threat_detection_policy = false
  storage_size            = 5120
  engine_version          = 11
  backup_retention_days   = 7
  username                = "pgadmin"
  password                = random_password.password.result
  resource_group_name     = var.resource_group_name
  location                = var.location
  prefix                  = var.prefix
  allowed_ips             = var.allowed_ips
}

module "postgresql_production" {
  source = "./postgresql"
  name   = "production"
  sku    = "B_Gen5_1"
  databases = {
    prod-db1 = { name = "prod-db1",
    charset = "UTF8",
    collation = "English_United States.1252" },
    prod-db2 = { name = "prod-db2",
    charset = "UTF8",
    collation = "English_United States.1252" }
  }
  backup                  = true
  threat_detection_policy = false
  storage_size            = 5120
  engine_version          = 11
  backup_retention_days   = 7
  username                = "pgadmin"
  password                = random_password.password.result
  resource_group_name     = var.resource_group_name
  location                = var.location
  prefix                  = var.prefix
  allowed_ips             = var.allowed_ips
}

resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "%@!"
}

resource "azurerm_app_service_plan" "default" {
  name                = format("%s-%s-app-service-plan-%s", var.prefix, terraform.workspace, random_integer.app_service_plan.id)
  kind                = "Linux"
  reserved            = true
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = var.azurerm_app_service_sku_tier
    size = var.azurerm_app_service_sku_size
  }
}

module "app-service" {
  source                         = "./app-service"
  app_service_plan_id            = azurerm_app_service_plan.default.id
  for_each = {
    nginx = {
     service_name                    = "nginx"
     image                           = "nginx"
     image_version                   = "latest"
     health_check_path               = "/"
     health_check_max_ping_failures  = "2"
     ip_restriction                  = {
       100 = {
          priority                  = 100
          action                    = "Allow"
          name                      = "app-gw"
          virtual_network_subnet_id = "/subscriptions/a0428382-057e-415e-b01f-0eb0d6b4fbc8/resourceGroups/abiels-dev-rg-001/providers/Microsoft.Network/virtualNetworks/abiels-dev-vnet-8/subnets/abiels-dev-subnet-gateway-8"
        }
     }
     },
    getting-started = {
     service_name = "getting-started"
     image                           = "docker/getting-started"
     image_version                   = "latest"
     health_check_path               = "/"
     health_check_max_ping_failures  = "2"
     ip_restriction                  = {
       100 = {
          priority                  = 100
          action                    = "Allow"
          name                      = "app-gw"
          virtual_network_subnet_id = "/subscriptions/a0428382-057e-415e-b01f-0eb0d6b4fbc8/resourceGroups/abiels-dev-rg-001/providers/Microsoft.Network/virtualNetworks/abiels-dev-vnet-8/subnets/abiels-dev-subnet-gateway-8"
        }
     }
    },
    nginx-public = {
     service_name                    = "nginx-public"
     image                           = "nginx"
     image_version                   = "latest"
     health_check_path               = "/"
     health_check_max_ping_failures  = "2"
     ip_restriction                  = {}
     }
  }
  service_name                   = each.value.service_name
  image                          = each.value.image
  image_version                  = each.value.image_version
  health_check_path              = each.value.health_check_path
  health_check_max_ping_failures = each.value.health_check_max_ping_failures
  ip_restriction                 = each.value.ip_restriction
  resource_group_name            = var.resource_group_name
  location                       = var.location
  prefix                         = var.prefix
}

module "application_gateway" {
  source        = "./application-gateway"
  vnet_name     = "abiels-dev-vnet-8"
  subnet_name   = "abiels-dev-subnet-gateway-8"
  app_gw_name   = "demo1"
  sku_name      = "Standard_v2"
  tier_name     = "Standard_v2"
  sku_capacity  = 1
  frontend_port = 80
  backend_address_pools = [
    {
      name  = "nginx"
      fqdns = ["abiels-dev-app-service-nginx-493.azurewebsites.net"]
    },
    {
      name  = "getting-started"
      fqdns = ["abiels-dev-app-service-getting-started-250.azurewebsites.net"]
    }
  ]
  backend_http_settings = [
    {
      name                                = "listener_http_80"
      path                                = "/"
      port                                = 80
      request_timeout                     = 30
      cookie_based_affinity               = "Disabled"
      probe_name                          = "http_80"
      protocol                            = "Http"
      pick_host_name_from_backend_address = true
    }
  ]
  request_routing_rule = [
    {
      http_listener_name = "appgw-demo1-http_listener"
      name               = "Path_Based_Rules"
      rule_type          = "PathBasedRouting"
      url_path_map_name  = "Path_Based"
    }
  ]
  url_path_maps = [
    {
      name                               = "Path_Based"
      default_backend_address_pool_name  = "getting-started"
      default_backend_http_settings_name = "listener_http_80"

      path_rules = [{
        backend_address_pool_name  = "getting-started"
        backend_http_settings_name = "listener_http_80"
        name                       = "getting-starred"
        paths = [
          "/getting-starred",
          "/tutorial",
        ]
    },
    {
        backend_address_pool_name  = "nginx"
        backend_http_settings_name = "listener_http_80"
        name                       = "nginx"
        paths = [
         "/nginx/",
        ]
    },
    {
        backend_address_pool_name  = "nginx"
        backend_http_settings_name = "listener_http_80"
        name                       = "nginx2"
        paths = [
          "/nginx2/",
        ]
    }]
    }
  ]
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix
  public_ip_number    = random_integer.public_ip.id
  app_gw_number       = random_integer.app_gw.id
  depends_on = [
    module.virtual-network,
    module.app-service
  ]
}
