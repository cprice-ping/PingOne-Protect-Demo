# Terraform

The HCL contains resources for PingOne \ DaVinci.  

Optionally, there are additional HCL using the K8s provider that can be used to deploy the application image with an associated Ingress to allow browser access to the container.

## Providers

The Terraform here uses multiple providers:

| Provider | Description |
| --- | --- |
| **PingOne** | PingOne Environment \ Services configuration |
| **DaVinci** | PingOne DaVinci Flow & Application |
| **[Optional] Kubernetes** | Configure k8s infrastructure components |

## Terraform Resources

This is what the HCL will create

| Provider | Resource | Description |
| --- | --- | --- |
| PingOne | Environment | Contains all the P1 configuration for the app |
| PingOne | Application | OIDC App used by the app |
| PingOne | Resource Grant | Assigns resources \ scopes to the OIDC App |
| DaVinci | Flow | Import of the Flow JSON |
| DaVinci | Application | Flow assigned to a Policy |

### Application Deployment

If you'd like to also deploy the application via Terraform, the [app-deploy](./app-deploy/) folder contains additional HCL files that can be copied into this folder and modified to your deployment spec.

## Variables

In the `/terraform` folder, create a `terraform.tfvars` file with the following:

```hcl
region = "{{ NorthAmerica | Canada | Asia | Europe }}"
organization_id = "{{orgId}}"
admin_env_id = "{{adminEnvId}}"
admin_user_id = "{{adminUserId}}"
admin_user_name = "{{Admin Username - needed for DV}}"
admin_user_password = "{{Admin User Password - needed for DV}}"
license_name = "{{License name to put on new Env}}"
worker_id = "{{workerId}}"
worker_secret = "{{workerSecret}}"
env_name = "{{PingOne Environment Name to create}}"
```

## **Deployment**

At a command line:

```zsh
terraform init
terraform plan
```

If the plan fails - check your `terraform.tfvars` values.

If the plan succeeds:

```hcl
terraform apply —auto-approve
````

If successful, you should be given the URL of the application that you can access with a browser
