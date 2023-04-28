########################
# Copy the below into the `/terraform/versions.tf` file
########################
provider "kubernetes" {
  config_path = "~/.kube/config"
}