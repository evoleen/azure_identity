# Azure Identity Client

This package is a very rough and simplified version of [Azure Identity](https://www.npmjs.com/package/@azure/identity) for Dart.

Azure Identity provides token authentication mechanisms via Microsoft Entra ID identities. Since different authentication mechanisms are supported, it can be used to authenticate locally with a service deployed on Azure but can also be used to authenticate a Dart service with another service deployed on Azure.

Microsoft offers implementations for different architectures, but no implementation exists for Dart. This code serves as an intermediate solution by providing a `BridgedDefaultAzureCredential()` implementation that exposes the same interface as `@azure/identity` for NodeJS but uses a pre-compiled NodeJS binary in the background to call the native `DefaultAzureCredential` implementation.

This method is not very efficient but straightforward. Contributions to implement various credential methods natively in Dart are welcome.

## Supported platforms

As the package depends on a cross-compiled NodeJS executable, only platforms supported by the Bun runtime for cross-compilation are supported.

- macOS
- Linux

Windows support is theoretically possible, but Bun crashes during installation. It is anticipated that this will be resolved with future Bun versions.

## Integration

The package ships with a compiled version of the `fetch_token` binary. If the final application is executed through the Dart interpreter, the package is able to automatically locate the platform-specific binary file and will execute it.

If the final application is compiled to an executable, Dart is unable to package the `fetch_token` binary with the executable. The binary then needs to be added manually and path of the binary needs to be supplied to `BridgedDefaultAzureCredential()`.
