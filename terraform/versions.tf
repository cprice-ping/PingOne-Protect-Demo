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
    docker = {
      source  = "kreuzwerker/docker"
    #   version = "3.0.2"
    }
  }
}