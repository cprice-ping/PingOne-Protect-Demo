# PingOne Protect Sample App

The default page shows native JS integration with Signals SDK

It also shows how to perform the P1 Protect Evaluation call from within your application framework. Since this call requires a P1 Worker token, it **must** be made somewhere other than the client application - in this application, it's a Fastify service.

There is also a page that uses OIDC to launch a DaVinci flow that contains a User Journey

## Deployment

There are several ways to deploy the sample application:

* Local NodeJS (v20.x)
* Local Docker
* K8s
* No App

### **Local NodeJS**

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

### **Local Docker**

The sample app is also available using Docker:

```zsh
docker run -p 3000:3000 -e envId={{ Your deployed Environment }} -e oidcClientId={{ Client_ID of the OIDC login app }} -e workerId={{ Client_ID of a Worker App (Client_Secret_Basic) }} -e workerSecret={{ Client_Secret of the Worker App }} pricecs/p1-protect-demo:latest
```

### Kubernetes

You can deploy the app into Kubernetes using Terraform.
