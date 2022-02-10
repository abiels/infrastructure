

resource "azurerm_app_service" "app-service" {
  name                = format("%s-%s-app-service-%s-%s", var.prefix, terraform.workspace, var.service_name, random_integer.app_service.id)
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version  = format("DOCKER|%s:%s", var.image, var.image_version)
    always_on         = "true"
    health_check_path = var.health_check_path
  }
  app_settings = {
    "WEBSITE_HEALTHCHECK_MAXPINGFAILURES" = var.health_check_max_ping_failures
  }
}

resource "random_integer" "app_service" {
  min = 001
  max = 500
}
