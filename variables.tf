variable "prefix" {
  type    = string
  default = "abiels"
}
variable "location" {
  type    = string
  default = "West Europe"
}
variable "allowed_ips" {
  type = map(string)
  default = {
    abiels = "109.251.247.244/32"
    sbahl  = "176.36.130.65/32"
  }
}
variable "resource_group_name" {
  type    = string
  default = "abiels-dev-rg-001"
}
variable "vnet_address_space" {
  type    = string
  default = "10.0.0.0/16"
}
variable "subnets" {
  type = map(object({
    name       = string
    addr_range = string
  }))
  default = {
    "app" = {
      name       = "app"
      addr_range = "10.0.1.0/24"
    }
  }
}
variable "postgresql" {
  type = map(object({
    name                    = string
    size                    = string
    databases               = list(string)
    backup                  = bool
    threat_detection_policy = bool
    storage_size            = number
    engine_version          = string
    backup_retention_days   = number
  }))
  default = {
    "dev" = {
      name                    = "development"
      size                    = "B_Gen5_1"
      databases               = ["dev-db1", "dev-db2"]
      backup                  = false
      threat_detection_policy = false
      storage_size            = 5120
      engine_version          = 11
      backup_retention_days   = 7
    },
    "prod" = {
      name                    = "production"
      size                    = "B_Gen5_1"
      databases               = ["prod-db1", "prod-db2"]
      backup                  = true
      threat_detection_policy = true
      storage_size            = 5120
      engine_version          = 11
      backup_retention_days   = 7
    }
  }
}
variable "secret_officers" {
  type    = map(string)
  default = { abiels = "916cbac1-db2e-433c-9842-3b24ce2570d2" }
}
