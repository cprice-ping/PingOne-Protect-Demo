output "dv_worker_secret" {
  value = pingone_application.dv_worker_app.oidc_options[0].client_secret
  sensitive=true
}

output "docker_run_command" {
  value = "docker run -p 3000:3000 -e ENVID=${pingone_environment.release_environment.id} -e OIDCCLIENTID=${pingone_application.app_logon.oidc_options[0].client_id} -e WORKERID=${pingone_application.dv_worker_app.oidc_options[0].client_id} -e WORKERSECRET={{run `terraform output workerSecret` to see}} pricecs/p1-protect-demo:latest"
}

output "app_url" {
  value = local.app_url
}

output "oidc_url" {
  value = "https://auth.pingone.${local.pingone_domain}/${pingone_environment.release_environment.id}/as/authorize?client_id=${pingone_application.app_logon.oidc_options[0].client_id}&response_type=token id_token&scope=openid email profile&redirect_uri=https://decoder.pingidentity.cloud/hybrid"
}