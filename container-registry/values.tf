variable "resource_group_name" {
  type = string
}
variable "resource_location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "allowed_ips" {
  type = map(string)
}
