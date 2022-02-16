variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "prefix" {
  type = string
}
variable "sku_name" {
  type = string
}
variable "tier_name" {
  type = string
}
variable "sku_capacity" {
  type = number
}
variable "frontend_port" {
  type = number
}
variable "app_gw_name" {
  type = string
}
variable "public_ip_number" {
  type = string
}
variable "app_gw_number" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "backend_address_pools" {
  type = list(object({
    name  = string
    fqdns = list(string)
  }))
}
variable "backend_http_settings" {
  type = list(object({
    name                                = string
    path                                = string
    request_timeout                     = string
    port                                = string
    cookie_based_affinity               = string
    probe_name                          = string
    protocol                            = string
    pick_host_name_from_backend_address = bool
  }))
}
variable "request_routing_rule" {
  type = list(object({
    http_listener_name = string
    name               = string
    rule_type          = string
    url_path_map_name  = string
  }))
}
variable "url_path_maps" {
  type = list(object({
    name                                = string
    default_backend_http_settings_name  = string
    default_backend_address_pool_name   = string
    
    path_rules = list(object({
      name                        = string
      backend_address_pool_name   = string
      backend_http_settings_name  = string
      paths                       = list(string)
    }))
  }))
}
