# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
#changes to push

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
