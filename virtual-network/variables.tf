variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "vnet_address_space" {
  type = string
}
variable "subnets" {
  type = map(object({
    name    = string
    addr_range = string
  }))
}
