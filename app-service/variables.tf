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
variable "services" {
  type = map(object({
    service_name                   = string
    image                          = string
    image_version                  = string
    health_check_path              = string
    health_check_max_ping_failures = string
  }))
}
