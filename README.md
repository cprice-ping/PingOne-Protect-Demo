# PingOne Protect Demo

This package contains everything you need to demonstrate PingOne Protect.

It contains:

* Configuration
* DaVinci Flows
* Sample Application

## Configuration

Configuration can be managed using Terraform with the PingOne & PingOne DaVinci providers.

Examine the [/terraform](/terraform) folder for what is needed.

## DaVinci Flows

A set of [DaVinci](/davinci/) flows are included and are used by the Sample Application.

The Flows can be deployed with Terraform, or manually imported into a DaVinci instance.

## Sample Application

A simple application is also included that can be used to demonstrate PingOne Protect and the Signals SDK.

The default page shows native JS integration with Signals SDK

It also shows how to perform the P1 Protect Evaluation call from within your application framework. Since this call requires a P1 Worker token, it **must** be made somewhere other than the client application - in this application, it's a Fastify service.

### Deployment

There are several ways to deploy the sample application:

* Local NodeJS (v20.x)
* Local Docker
* K8s

#### **Local NodeJS**

Switch to the `/app` folder.
Create a `.env` file with the following:

```zsh
# P1 Protect
envId={{ Your deployed Environment }}
oidcClientId={{ Client_ID of the OIDC login app }}
workerId={{ Client_ID of a Worker App (Client_Secret_Basic) }}
workerSecret={{ Client_Secret of the Worker App }}
```

The application should launch and be available on [https://localhost:3000](https://localhost:3000)


#### **Local Docker**

The sample app is also available using Docker:

```zsh
docker run -p 3000:3000 -e envId={{ Your deployed Environment }} -e oidcClientId={{ Client_ID of the OIDC login app }} -e workerId={{ Client_ID of a Worker App (Client_Secret_Basic) }} -e workerSecret={{ Client_Secret of the Worker App }} pricecs/p1-protect-demo:latest
```

#### Kubernetes

You can deploy the app into Kubernetes using Terraform.
