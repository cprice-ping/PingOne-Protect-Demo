provider "davinci" {
  //Must be Identity Data Admin for Environment 
  username = var.dv_admin_user_name
  password = var.dv_admin_user_password
  region   = var.region
  // User should exist in Identities of this environment
  environment_id = var.admin_env_id
}

// Get the ID of the DV admin user
data "pingone_user" "dv_admin_user" {
  environment_id = var.admin_env_id

  username = var.dv_admin_user_name
}

// Assign the "Identity Data Admin" role to the DV admin user
resource "pingone_role_assignment_user" "admin_sso_identity_admin" {
  environment_id       = var.admin_env_id
  user_id              = data.pingone_user.dv_admin_user.id
  role_id              = data.pingone_role.identity_data_admin.id
  scope_environment_id = pingone_environment.release_environment.id
}

// Assign the "Environment Admin" role to the DV admin user
resource "pingone_role_assignment_user" "admin_sso_environment_admin" {
  environment_id       = var.admin_env_id
  user_id              = data.pingone_user.dv_admin_user.id
  role_id              = data.pingone_role.environment_admin.id
  scope_environment_id = pingone_environment.release_environment.id
}

// This simple read action is used to as a precursor to all other data/resources
// Every other data/resource should have a `depends_on` pointing to this read action
data "davinci_connections" "read_all" {
  // NOTICE: This read action has a dependency on the role assignment, not environment.
  // Assigning this correctly ensures the role is not destroyed before DaVinci resources during `terraform destroy`.
  depends_on = [
    pingone_role_assignment_user.admin_sso_identity_admin,
    pingone_role_assignment_user.admin_sso_environment_admin
  ]
  environment_id = pingone_environment.release_environment.id
}


# resource "davinci_flow" "initial_flow" {
#   flow_json = file("../DaVinci/demo_flow.json")
#   deploy    = true
#   // NOTICE: this is NOT resource.pingone_environment. Dependency is on the role assignment, not environment.
#   environment_id = module.environment.identity_data_admin_role[0].scope_environment_id

#   connections {
#     connection_id   = "867ed4363b2bc21c860085ad2baa817d"
#     connection_name = "Http"
#   }

#   // This depends_on relieves the client from multiple initial authentication attempts
#   depends_on = [
#     data.davinci_connections.read_all
#   ]
# }

# resource "davinci_flow" "second_flow" {
#   flow_json = file("../DaVinci/demo_flow_2.json")
#   deploy    = true
#   // NOTICE: this is NOT resource.pingone_environment. Dependency is on the role assignment, not environment.
#   environment_id = module.environment.identity_data_admin_role[0].scope_environment_id

#   connections {
#     connection_id   = "867ed4363b2bc21c860085ad2baa817d"
#     connection_name = "Http"
#   }

#   // This depends_on relieves the client from multiple initial authentication attempts
#   depends_on = [
#     data.davinci_connections.read_all
#   ]
# }

resource "davinci_application" "initial_policy" {
  name           = "PingOne Protect Application"
  environment_id = pingone_environment.release_environment.id
  oauth {
    enabled = true
    values {
      allowed_grants                = ["authorizationCode"]
      allowed_scopes                = ["openid", "profile"]
      enabled                       = true
      enforce_signed_request_openid = false
      redirect_uris                 = ["https://auth.pingone.com/${pingone_environment.release_environment.id}/rp/callback/openid_connect"]
    }
  }
  # policies {
  #   name   = "Sample App Flow"
  #   status = "enabled"
  #   policy_flows {
  #     flow_id    = davinci_flow.initial_flow.flow_id
  #     version_id = -1
  #     weight     = 100
  #   }
  # }
  # policies {
  #   name   = "Second App Flow"
  #   status = "enabled"
  #   policy_flows {
  #     flow_id    = davinci_flow.second_flow.flow_id
  #     version_id = -1
  #     weight     = 100
  #   }
  # }
  saml {
    values {
      enabled                = false
      enforce_signed_request = false
    }
  }
}