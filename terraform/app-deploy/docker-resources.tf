####################################################################################################
# Optional Docker Image Resources.
# {@link https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs}
####################################################################################################
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Pulls the image
resource "docker_image" "pingone_protect_demo" {
  name  = "pricecs/p1-protect-demo:latest"
}

# Create a container
resource "docker_container" "local_pingone_protect" {
  image = docker_image.pingone_protect_demo.image_id
  name  = "PingOne_Protect_Demo"
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "ENVID=${pingone_environment.release_environment.id}",
    "OIDCCLIENTID=${pingone_application.app_logon.oidc_options[0].client_id}",
    "WORKERID=${pingone_application.dv_worker_app.oidc_options[0].client_id}",
    "WORKERSECRET=${pingone_application.dv_worker_app.oidc_options[0].client_secret}"
  ]
}