variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "app_service_plan_id" {
  type = string
}
variable "service_name" {
  type = string
}
variable "image" {
  type = string
}
variable "image_version" {
  type = string
}
variable "health_check_path" {
  type = string
  default = "/"
}
variable "health_check_max_ping_failures" {
  type = string
  default = "2"
}
