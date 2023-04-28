####################################################################################################
# Optional Docker Image Resources.
# {@link https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs}
####################################################################################################

# Pulls the image
resource "docker_image" "pingone_protect-demo" {
  name  = "pricecs/pingone-protect-demo:latest"
}

# Create a container
resource "docker_container" "local_pingone_protect" {
  image = docker_image.pingone_protect_demo.id
  name  = "PingOne_Protect_Demo"
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "env_id = ${pingone_environment.release_environment.id}",
    "oidcClientId = ${pingone_application.app_logon.oidc_options[0].client_id}",
    "workerId = ${pingone_application.dv_worker_app.oidc_options[0].client_id}",
    "workerSecret = ${pingone_application.dv_worker_app.oidc_options[0].client_secret}"
  ]
}