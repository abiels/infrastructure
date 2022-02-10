
resource "azurerm_app_service_plan" "service_plan" {
  name                = format("%s-%s-app-service-plan-%s-", var.prefix, terraform.workspace, random_integer.app_service.id)
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
}

resource "azurerm_app_service" "app-service" {
  name                = format("%s-%s-app-service-%s-%s", var.prefix, terraform.workspace, var.service_name, random_integer.app_service.id)
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.service_plan.id

  site_config {
    use_32_bit_worker_process = var.use_32_bit_worker_process 
    dotnet_framework_version  = var.dotnet_framework_version
    scm_type                  = var.scm_type
  }

}

resource "random_integer" "app_service" {
  min = 001
  max = 500
}
