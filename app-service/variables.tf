variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "sku_tier" {
  type = string
}
variable "sku_size" {
  type = string
}
variable "service_name" {
  type = string
}
variable use_32_bit_worker_process {
  type = bool
}
variable dotnet_framework_version  {
  type = string
}
variable scm_type {
  type = string
}
