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
variable "backend_http_patch" {
  type    = string
  default = "/"
}
variable "backend_http_port" {
  type    = number
  default = 80
}
variable "backand_http_protocol" {
  type    = string
  default = "http"
}
