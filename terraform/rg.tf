resource "azurerm_resource_group" "azdo-agent" {
  location = module.global.location
  name     = "azdo-agent"
}