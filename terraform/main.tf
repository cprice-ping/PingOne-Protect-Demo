provider "pingone" {
  client_id                    = var.worker_id
  client_secret                = var.worker_secret
  environment_id               = var.admin_env_id
  region                       = var.region
  force_delete_production_type = false
}

data "pingone_licenses" "internal_license" {
  organization_id = var.organization_id

  data_filter {
    name   = "package"
    values = ["INTERNAL"]
  }

  data_filter {
    name   = "status"
    values = ["ACTIVE"]
  }
}

resource "pingone_environment" "release_environment" {
  name        = var.env_name
  description = "Used to demo P1 Protect with OIDC & DV"
  type        = "SANDBOX"
  license_id  = data.pingone_licenses.internal_license.ids[0]

  default_population {}
  service {
    type = "SSO"
  }
  # service {
  #   type = "MFA"
  # }
  service {
    type = "Risk"
  }
  # service {
  #   type = "Authorize"
  # }
  service {
    type = "DaVinci"
  }

  # service {
  #   type = "Verify"
  # }
}

# Grant Roles to Admin User
data "pingone_role" "environment_admin" {
  name = "Environment Admin"
}

data "pingone_role" "identity_data_admin" {
  name = "Identity Data Admin"
}

data "pingone_role" "client_application_developer" {
  name = "Client Application Developer"
}

resource "pingone_role_assignment_user" "id_admin" {
  environment_id = var.admin_env_id
  user_id        = var.admin_user_id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = pingone_environment.release_environment.id
}

resource "pingone_role_assignment_user" "app_dev" {
  environment_id = var.admin_env_id
  user_id        = var.admin_user_id
  role_id        = data.pingone_role.client_application_developer.id

  scope_environment_id = pingone_environment.release_environment.id
}

resource "pingone_population" "app" {
  environment_id = pingone_environment.release_environment.id

  name        = "Application Users"
  description = "Population containing App Users"
}

# PingOne Sign-On Policy
resource "pingone_sign_on_policy" "app_logon" {
  environment_id = pingone_environment.release_environment.id

  name        = "App_Logon"
  description = "Simple Login with Registration"
}

resource "pingone_sign_on_policy_action" "app_logon_first" {
  environment_id    = pingone_environment.release_environment.id
  sign_on_policy_id = pingone_sign_on_policy.app_logon.id

  registration_local_population_id = pingone_population.app.id

  priority = 1

  conditions {
    last_sign_on_older_than_seconds = 3600 // 1 Hour
  }

  login {
    recovery_enabled = true
  }
}

resource "pingone_application" "app_logon" {
  environment_id = pingone_environment.release_environment.id
  enabled        = true
  name           = "P1 Protect - DV"

  oidc_options {
    type                        = "NATIVE_APP"
    grant_types                 = ["AUTHORIZATION_CODE", "IMPLICIT"]
    response_types              = ["CODE", "TOKEN", "ID_TOKEN"]
    token_endpoint_authn_method = "NONE"
    redirect_uris               = ["${local.app_url}"]
  }
}

data "pingone_resource" "openid" {
  environment_id = pingone_environment.release_environment.id

  name = "openid"
}

data "pingone_resource" "pingone" {
  environment_id = pingone_environment.release_environment.id

  name = "PingOne API"
}

data "pingone_resource_scope" "openid_email" {
  environment_id = pingone_environment.release_environment.id
  resource_id    = data.pingone_resource.openid.id

  name = "email"
}

data "pingone_resource_scope" "openid_profile" {
  environment_id = pingone_environment.release_environment.id
  resource_id    = data.pingone_resource.openid.id

  name = "profile"
}

data "pingone_resource_scope" "pingone_read_user" {
  environment_id = pingone_environment.release_environment.id
  resource_id    = data.pingone_resource.pingone.id

  name = "p1:read:user"
}

data "pingone_resource_scope" "pingone_update_user" {
  environment_id = pingone_environment.release_environment.id
  resource_id    = data.pingone_resource.pingone.id

  name = "p1:update:user"
}

data "pingone_resource_scope" "pingone_read_sessions" {
  environment_id = pingone_environment.release_environment.id
  resource_id    = data.pingone_resource.pingone.id

  name = "p1:read:sessions"
}

resource "pingone_application_resource_grant" "app_login_openid" {
  environment_id = pingone_environment.release_environment.id
  application_id = pingone_application.app_logon.id

  resource_id = data.pingone_resource.openid.id

  scopes = [
    data.pingone_resource_scope.openid_email.id,
    data.pingone_resource_scope.openid_profile.id
  ]
}

resource "pingone_application_resource_grant" "app_login_pingone" {
  environment_id = pingone_environment.release_environment.id
  application_id = pingone_application.app_logon.id

  resource_id = data.pingone_resource.pingone.id

  scopes = [
    data.pingone_resource_scope.pingone_read_user.id,
    data.pingone_resource_scope.pingone_update_user.id,
    data.pingone_resource_scope.pingone_read_sessions.id
  ]
}

resource "pingone_application_sign_on_policy_assignment" "app_logon" {
  environment_id = pingone_environment.release_environment.id
  application_id = pingone_application.app_logon.id

  sign_on_policy_id = pingone_sign_on_policy.app_logon.id

  priority = 1
}