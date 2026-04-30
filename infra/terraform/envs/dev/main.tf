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

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "devopstfstate987654"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
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
  depends_on = [module.aks]
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

# Enable Azure Defender for Containers
resource "azurerm_security_center_subscription_pricing" "defender_containers" {
  tier          = "Standard"
  resource_type = "Containers"
}