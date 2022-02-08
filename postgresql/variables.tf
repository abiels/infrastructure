variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "allowed_ips" {
  type = map(string)
}
variable "name" {
  type = string
}
variable "sku" {
  type = string
}
variable "databases" {
  type = map(object({
    name      = string
    charset   = string
    collation = string
  }))
}
variable "backup" {
  type = bool
}
variable "threat_detection_policy" {
  type = bool
}
variable "storage_size" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "backup_retention_days" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
