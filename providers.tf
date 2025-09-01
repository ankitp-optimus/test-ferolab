terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.1.0"
}

# This will be used to manage Azure resources in the FeroLabs Corporate Connectivity Terraform module.
provider "azurerm" {
  features {}
    client_id       = "<your-app-registration-client-id>"
    client_secret   = "<your-app-registration-client-secret>"
    tenant_id       = "<your-azure-tenant-id>"
    subscription_id = var.subscription_id
} 

# This provider is used to manage resources in the production subscription
provider "azurerm" {
  features {
    
  }
  alias           = "prd_sub"
  client_id       = "<your-app-registration-client-id>"
  client_secret   = "<your-app-registration-client-secret>"
  tenant_id       = "<your-azure-tenant-id>"
  subscription_id = var.prd_subscription_id
}