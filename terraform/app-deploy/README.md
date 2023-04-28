# Application Deployment with Terraform

You can use Terraform to deploy the PingOne Protect application - supplied in this folder are various flavors.

Each flavor contains 2 files:

| File Pattern | Description |
| --- | --- |
| `{deployment}-provider.tf` | This should be merged into the `/terraform/versions.tf` file |
| `{deployment}-resources.tf` | This should be copied into the `/terraform` folder and modified for your environment |

## Docker

The `docker-resources.tf` should be ready to use, as the only requirement is Docker running on the machine you're executing Terraform on.

| Provider | Resource | Description |
| --- | --- | --- |
| Docker | Container | Deploy a local container of the app image |

The Docker image will be assumed to be running on `http://localhost:3000`

## K8s

Kubernetes is inherently more complex to deploy into.

The `k8s-resource.tf` shows an example of deploying the Application as a k8s Deployment with a Service and Ingress added to enable external access.

| Provider | Resource | Description |
| --- | --- | --- |
| Kubernetes | Deployment | Deploy the sample app |
| Kubernetes | Service | Service pointing to the deployed app |
| Kubernetes | Ingress | Inbound access to deployed app |