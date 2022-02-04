variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "postgresql" {
}
variable "allowed_ips" {
  type = map(string)
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
