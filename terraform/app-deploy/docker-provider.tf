########################
# Copy the below into the `/terraform/versions.tf` file
########################

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    #   version = "3.0.2"
    }
  }
}