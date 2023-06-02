resource "azurerm_resource_group" "hub_spoke_rg" {
  name     = var.resourcegroup_name
  location = var.location
}