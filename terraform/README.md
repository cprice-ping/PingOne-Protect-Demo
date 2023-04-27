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

[Optional]
| Provider | Resource | Description |
| --- | --- | --- |
| K8s | Deployment | Deploy the sample app |
| K8s | Service | Service pointing to the deployed app |
| K8s | Ingress | Inbound access to deployed app |

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

### **Deploying the Demo App**

* Copy the `/terraform/app-deploy/k8s.tf` into the `/terraform` folder.
* Uncomment the lines in `/terraform/vars.tf`
* Add the following variables to `terraform.tfvars`

```hcl
k8s_deploy_name = "{{ Name for k8s to use in deployment}}"
k8s_namespace = "{{ k8s namespace to deploy into}}"
app_image_name="pricecs/p1-protect-demo:0.0.2"
k8s_deploy_domain="{{ DNS domain to use for Ingress }}"
