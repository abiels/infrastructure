variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "os_disk_storage_account_type" {
  type = string
}
variable "vm_size" {
  type = string
}
variable "source_image_reference" {
  type = object({ publisher = string
    offer   = string
    sku     = string
    version = string
  })
}
variable "os_username" {
  type = string
}
variable "os_password" {
  type = string
}

variable "network_security_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
variable network_name {
  type = string
}
variable subnet_name {
  type = string
}

