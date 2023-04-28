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
data "davinci_connections" "all" {
  // NOTICE: This read action has a dependency on the role assignment, not environment.
  // Assigning this correctly ensures the role is not destroyed before DaVinci resources during `terraform destroy`.
  depends_on = [
    pingone_role_assignment_user.admin_sso_identity_admin,
    pingone_role_assignment_user.admin_sso_environment_admin
  ]
  environment_id = pingone_environment.release_environment.id
}

# Get the boostrapped Connectors we need
data "davinci_connections" "pingone" {
  environment_id = pingone_environment.release_environment.id
  // This will filter output to only include connections using the "httpConnector" type. 
  // Helpful for validation that only one of a certain type exists.
  connector_ids = ["pingOneSSOConnector"]
}

## Create non-Bootstrapped Connectors
# PingOne Notifications
resource "davinci_connection" "pingone_notifications" {
  name           = "PingOne Notifications"
  connector_id   = "notificationsConnector"
  environment_id = pingone_environment.release_environment.id

  property {
    name  = "clientId"
    value = pingone_application.dv_worker_app.oidc_options[0].client_id
  }
  property {
    name  = "clientSecret"
    value = pingone_application.dv_worker_app.oidc_options[0].client_secret
  }
  property {
    name  = "envId"
    value = pingone_environment.release_environment.id
  }
  property {
    name  = "region"
    value = local.pingone_short
  }

  depends_on = [data.davinci_connections.all]
}

# PingOne Protect
resource "davinci_connection" "pingone_protect" {
  name           = "PingOne Protect"
  connector_id   = "pingOneRiskConnector"
  environment_id = pingone_environment.release_environment.id

  property {
    name  = "clientId"
    value = pingone_application.dv_worker_app.oidc_options[0].client_id
  }
  property {
    name  = "clientSecret"
    value = pingone_application.dv_worker_app.oidc_options[0].client_secret
  }
  property {
    name  = "envId"
    value = pingone_environment.release_environment.id
  }
  property {
    name  = "region"
    value = local.pingone_short
  }

  depends_on = [data.davinci_connections.all]
}

resource "davinci_connection" "pingone_authentication" {
  name           = "PingOne Authentication"
  connector_id   = "pingOneAuthenticationConnector"
  environment_id = pingone_environment.release_environment.id

  depends_on = [data.davinci_connections.all]
}

resource "davinci_connection" "teleport" {
  name           = "Teleport"
  connector_id   = "nodeConnector"
  environment_id = pingone_environment.release_environment.id

  depends_on = [data.davinci_connections.all]
}

resource "davinci_connection" "flow_conductor" {
  name           = "Flow Connector"
  connector_id   = "flowConnector"
  environment_id = pingone_environment.release_environment.id

  depends_on = [data.davinci_connections.all]
}

resource "davinci_flow" "initial_flow" {
  flow_json = file("../davinci/PingOne_Protect - Demo.json")
  deploy    = true

  environment_id = pingone_environment.release_environment.id

  subflow_link {
    id   = resource.davinci_flow.threat_assessment.id
    name = resource.davinci_flow.threat_assessment.name
  }

  connection_link {
    id   = "867ed4363b2bc21c860085ad2baa817d"
    name = "Http"
  }
  connection_link {
    id   = "921bfae85c38ed45045e07be703d86b8"
    name = "Annotation"
  }
  connection_link {
    id   = "de650ca45593b82c49064ead10b9fe17"
    name = "Functions"
  }
  connection_link {
    id   = "06922a684039827499bdbdd97f49827b"
    name = "Variables"
  }
  connection_link {
    id   = "6d8f6f706c45fd459a86b3f092602544"
    name = "Error Customize"
  }
  connection_link {
    id   = data.davinci_connections.pingone.id
    name = "PingOne"
  }
  connection_link {
    id   = davinci_connection.pingone_protect.id
    name = "PingOne Risk"
  }
  connection_link {
    id   = davinci_connection.teleport.id
    name = "Teleport"
  }
  connection_link {
    id   = davinci_connection.flow_conductor.id
    name = "Flow Conductor"
  }
  connection_link {
    id   = davinci_connection.pingone_authentication.id
    name = "PingOne Authentication"
  }
}

# Subflow - Perform Threat Assessment with New Device Notification
resource "davinci_flow" "threat_assessment" {
  environment_id = pingone_environment.release_environment.id
  flow_json      = file("../davinci/[Sub]_P1 Protect with New Device notification.json")
  deploy         = true
  connection_link {
    id   = "867ed4363b2bc21c860085ad2baa817d"
    name = "HTTP"
  }
  connection_link {
    id   = "921bfae85c38ed45045e07be703d86b8"
    name = "Annotation"
  }
  connection_link {
    id   = "de650ca45593b82c49064ead10b9fe17"
    name = "Functions"
  }
  connection_link {
    id   = data.davinci_connections.pingone.connector_ids[0]
    name = "Get Users Email"
  }
  connection_link {
    id   = davinci_connection.pingone_protect.id
    name = "PingOne Risk"
  }
  connection_link {
    id   = davinci_connection.pingone_notifications.id
    name = "PingOne Notifications"
  }
}

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
  policy {
    name   = "PingOne Protect Demo"
    status = "enabled"
    policy_flow {
      flow_id    = davinci_flow.initial_flow.id
      version_id = -1
      weight     = 100
    }
  }

  saml {
    values {
      enabled                = false
      enforce_signed_request = false
    }
  }
}