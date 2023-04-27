output "login_url" {
  value = local.app_url
}

output "release_environment_id" {
  value = pingone_environment.release_environment.id
}

output "oidc_client_id" {
  value = pingone_application.app_logon.oidc_options[0].client_id
}

output "dv_worker_id" {
  value = pingone_application.dv_worker_app.oidc_options[0].client_id
}

output "dv_worker_secret" {
  value = pingone_application.dv_worker_app.oidc_options[0].client_secret
  sensitive=true
}