variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "virtual_network_name" {
  type = string
}
variable "vnet_address_space" {
  type = string
}
variable "name" {
  type = string
}
variable "addr_range" {
  type = string
}
variable "service_endpoints" {
  type = list(string)
}
# variable "random_integer_vnet" {
#   type = string
# }
# variable "subnets" {
#   type = map(object({
#     name       = string
#     addr_range = string
#     service_endpoints = list(string)
#   }))
# }