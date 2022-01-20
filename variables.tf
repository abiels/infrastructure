variable "prefix" {
  type    = string
  default = "abiels"
}
variable "location" {
  type    = string
  default = "West Europe"
}
variable "kv_object_id" {
  type    = string
  default = "916cbac1-db2e-433c-9842-3b24ce2570d2"
}
variable "kv_soft_delete_retention_days" {
  type    = number
  default = 7
}
variable "kv_purge_protection_enabled" {
  type    = bool
  default = false
}
variable "kv_enabled_for_disk_encryption" {
  type    = bool
  default = true
}
variable "enable_rbac_authorization" {
  type    = bool
  default = true
}
