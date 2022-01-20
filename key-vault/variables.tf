variable "resource_group_name" {
  type = string
}
variable "resource_location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "kv_object_id" {
  type = string
}
variable "kv_soft_delete_retention_days" {
  type = number
}
variable "kv_purge_protection_enabled" {
  type = bool
}
variable "kv_enabled_for_disk_encryption" {
  type = bool
}
variable "enable_rbac_authorization" {
  type = bool
}
