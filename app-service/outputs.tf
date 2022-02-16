output "app_service_fqdns" {
  value = azurerm_app_service.app-service.default_site_hostname
}
