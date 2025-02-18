terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 4.0"
    }

    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.6"
    }
  }

  required_version = ">= 1.9.5"
}
