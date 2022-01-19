variable "prefix" {
  type    = string
  default = "abiels"
}
variable "location" {
  type    = string
  default = "West Europe"
}
variable "kv_tenant_id" {
  type    = string
  default = "6c1c659-9d52-41af-81f7-dde16380e813"
}
variable "kv_object_id" {
  type    = string
  default = "916cbac1-db2e-433c-9842-3b24ce2570d2"
}
variable "key_permissions" {
  type = list(any)
  default = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List",
  "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"]
}
variable "secret_permissions" {
  type    = list(any)
  default = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}

variable "storage_permissions" {
  type    = list(any)
  default = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
}
variable "kv_soft_delete_retention_days" {
  type    = number
  default = 7
}
variable "kv_purge_protection_enabled" {
  type    = bool
  default = false
}
variable "kv_sku_name" {
  type    = string
  default = "standard"
}
variable "kv_enabled_for_disk_encryption" {
  type    = bool
  default = true
}
