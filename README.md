# Azure Identity Client

This package is a simplified version of [Azure Identity](https://www.npmjs.com/package/@azure/identity) for Dart.

Azure Identity provides token authentication mechanisms via Microsoft Entra ID identities. Since different authentication mechanisms are supported, it can be used to authenticate locally with a service deployed on Azure but can also be used to authenticate a Dart service with another service deployed on Azure.

Microsoft offers implementations for different architectures, but no implementation exists for Dart. This package aims to be a starting point for building a similar, feature equivalent solution.

A first version of this package used a work-around by using a NodeJS shim that called `DefaultAzureCredential()`. The NodeJS shim was cross-compiled to a binary and executed via shell environment. While this had the downside of not being publishable on [pub.dev](https://pub.dev), it provided a very versatile initial solution. This version of the package is still available in the [bridged-implementation branch](https://github.com/evoleen/azure_identity/tree/bridged-implementation).

The current code is pure native Dart code and supports the following credentials:
- Managed Identity 2017 API version
- Managed Identity 2019 API version
- Azure CLI credential
- Chained credential
- Default credential (a chained credential of Managed Identity 2017, Managed Identity 2019, Azure CLI)
