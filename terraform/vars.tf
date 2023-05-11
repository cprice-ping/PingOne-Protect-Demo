variable "region" {
  type        = string
  description = "Region your P1 Org is in"
}

variable "organization_id" {
  type        = string
  description = "Your P1 Organization ID"
}

variable "license_name" {
  type        = string
  description = "Name of the P1 license you want to assign to the Environment"
}

variable "admin_env_id" {
  type        = string
  description = "P1 Environment containing the Worker App"
}

variable "admin_user_id" {
  type        = string
  description = "P1 Administrator to assign Roles to"
  sensitive   = true
}

variable "dv_admin_user_name" {
  type        = string
  description = "P1 Administrator username to connect to DaVinci with"
  sensitive   = true
}

variable "dv_admin_user_password" {
  type        = string
  description = "P1 Administrator password to connect to DaVinci with"
  sensitive   = true
}

variable "worker_id" {
  type        = string
  description = "Worker App ID App - App must have sufficient Roles"
  sensitive   = true
}

variable "worker_secret" {
  type        = string
  description = "Worker App Secret - App must have sufficient Roles"
  sensitive   = true
}

variable "env_name" {
  type        = string
  description = "Name used for the PingOne Environment"
}

variable "k8s_namespace" {
  type        = string
  description = "K8s namespace for container deployment"
}

variable "k8s_deploy_name" {
  type        = string
  description = "Name used in the K8s deployment of the App. Used in Deployment \\ Service \\ Ingress delivery"
}

variable "k8s_deploy_domain" {
  type        = string
  description = "DNS Domain used when creating the Ingresses"
}

# variable "app_policy_name" {
#   type        = string
#   description = "Name of the Policy you'd like to run - must be defined on the DaVinci Application"
# }

locals {
  # Swap if deployed with k8s
  # app_url = "https://${kubernetes_ingress_v1.package_ingress.spec[0].rule[0].host}"
  # Docker URL
  app_url = "http://localhost:3000"

  # Translate the Region to a Domain suffix
  north_america  = var.region == "NorthAmerica" ? "com" : ""
  europe         = var.region == "Europe" ? "eu" : ""
  canada         = var.region == "Canada" ? "ca" : ""
  asia_pacific   = var.region == "AsiaPacific" ? "asia" : ""
  pingone_domain = coalesce(local.north_america, local.europe, local.canada, local.asia_pacific)

  # Translate the Region to a Short Code
  na            = var.region == "NorthAmerica" ? "NA" : ""
  eu            = var.region == "Europe" ? "EU" : ""
  ca            = var.region == "Canada" ? "CA" : ""
  ap            = var.region == "AsiaPacific" ? "AP" : ""
  pingone_short = coalesce(local.na, local.eu, local.ca, local.ap)
}
