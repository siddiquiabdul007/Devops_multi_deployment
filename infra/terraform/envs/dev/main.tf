terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "aks_cluster" {
  source     = "../../modules/aks"
  
  location   = var.location
  prefix     = var.prefix
  env        = var.env
  node_count = var.node_count
  vm_size    = var.vm_size
}
