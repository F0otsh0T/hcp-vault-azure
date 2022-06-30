# versions.tf

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.11.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.1.0"
    }
  }
}





