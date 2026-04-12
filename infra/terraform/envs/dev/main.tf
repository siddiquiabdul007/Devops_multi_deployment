terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate unique suffix for ACR (important)
resource "random_integer" "rand" {
  min = 1000
  max = 9999
}

# Create ACR
module "acr" {
  source              = "../../modules/acr"
  acr_name            = "${var.prefix}${var.env}acr${random_integer.rand.result}"
  resource_group_name = "${var.prefix}-${var.env}-rg"
  location            = var.location
}

# Create AKS
module "aks" {
  source     = "../../modules/aks"

  location   = var.location
  prefix     = var.prefix
  env        = var.env
  node_count = var.node_count
  vm_size    = var.vm_size
}

# Allow AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = module.aks.kubelet_identity_object_id
  role_definition_name = "AcrPull"
  scope                = module.acr.acr_id
}