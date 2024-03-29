terraform {

  cloud {
    organization = "Kubeshop"

    workspaces {
      name = "botkube-azure-tf"
    }
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.73.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.11.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
