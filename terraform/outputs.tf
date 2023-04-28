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

output "oidc_url" {
  value = "https://auth.pingone.${local.pingone_domain}/${pingone_environment.release_environment.id}/as/authorize?client_id=${pingone_application.app_logon.oidc_options[0].client_id}&response_type=token id_token&scope=openid email profile&redirect_uri=https://decoder.pingidentity.cloud/hybrid"
}

output "docker_run_command" {
  value = "docker run -p 3000:3000 -e envId=${pingone_environment.release_environment.id} -e oidcClientId=${pingone_application.app_logon.oidc_options[0].client_id} -e workerId=${pingone_application.dv_worker_app.oidc_options[0].client_id} -e workerSecret={{DV Worker Secret}} pricecs/p1-protect-demo:latest"
}

output "pingone_connection" {
  value = data.davinci_connections.pingone
}