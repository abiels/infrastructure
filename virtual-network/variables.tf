variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}
variable "prefix" {
  type = string
}

variable "backend_http_patch" {
  type = string
}
variable "backend_http_port" {
  type = number
}
variable "backand_http_protocol" {
  type = string
}
