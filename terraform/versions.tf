terraform {
  required_providers {
    pingone = {
      source = "pingidentity/pingone"
    }
    davinci = {
      source = "pingidentity/davinci"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}