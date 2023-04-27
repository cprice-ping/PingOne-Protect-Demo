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

## PingOne Configuration

Several components of PingOne are needed for this demonstration:

* Environment
  * SSO
  * Davinci
  * Protect
* Applications
  * Worker App
  * OIDC Web App
* Protect
  * Predictors
  * Policy

All *except* the Protect configuration can be deployed with [Terraform](./terraform)

### Manual PingOne configuration

For things that cannot (yet) be performed with Terraform:

* Ask Product to enable the P1 Protect FFs in the created environment
* Add the Protect Predictors to the **default** Protect Policy
* Modify the score of the New Device Predictor to **50** in the Policy

### Manual DaVinci Changes

Currently, the `skRisk` component that is embedded in the Custom HTML Template requires the `envId` to be added. This isn't possible using Terraform.

* Launch DaVinci and open the *PingOne Protect - Demo* Flow
* Select the *Custom HTML Template - Start Form* node
  * Scroll to the bottom of the HTML
  * Click on the `skRisk` component
  * Add your EnvId to the component
  * ![skRisk Component](./davinci/skRisk%20Component.png)

## Sample Application

A sample application is also included that can be used to demonstrate PingOne Protect and the Signals SDK.

Information about deploying the app can be found [here](./app/)

### **No App**

You can trigger the DaVinci Flow without the App using a URL to make an OIDC request.

```zsh
https://auth.pingone.com/{{ Your Environment ID }}/as/authorize?client_id={{ OIDC Client ID }}&response_type=token id_token&redirect_uri=https://decoder.pingidentity.cloud/hybrid&scope=openid profile email
```
