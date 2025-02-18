terraform {
    required_providers {
      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = ">= 2.27"
      }
    }

    required_version = ">= 1.9.5"
}

data "terraform_remote_state" "k8s_cluster" {
  backend = "local"
  config = {
    path = "${path.module}/../provisioning/terraform.tfstate"
  }
}

provider "kubernetes" {
  host = "https://${data.terraform_remote_state.k8s_cluster.outputs.cluster_fqdn}"
  client_certificate     = base64decode(data.terraform_remote_state.k8s_cluster.outputs.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.k8s_cluster.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.k8s_cluster.outputs.cluster_ca_certificate)
}