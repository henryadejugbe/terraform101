terraform {
  backend "azurerm" {
    resource_group_name  = "rgproject0044"
    storage_account_name = "storage0004"
    container_name       = "container0004"
    key                  = "terraform.tfstate"
    }
}