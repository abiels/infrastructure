variable "prefix" {
  type    = string
  default = "abiels"
}
variable "location" {
  type    = string
  default = "West Europe"
}
variable "allowed_ips" {
  type = map(any)
  default = {
    abiels = "109.251.247.244/32"
  }
}
variable "resource_group_name" {
  type    = string
  default = "abiels-dev-rg-001"
}
