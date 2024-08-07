import 'package:azure_identity/azure_identity.dart';

/// Stripped down version of the Azure SDK's DefaultAzureCredential.
/// Will attempt the following authentication methods in sequence:
/// - Managed Identity 2019
/// - Managed Identity 2017
/// - Azure CLI
/// The original Azure SDK offers a few more methods in DefaultAzureCredential
/// which are not implemented in this package yet. However, the current methods
/// should provide a single token source for 75% of all use cases in
/// development and managed deployment scenarios.
class DefaultAzureCredential extends TokenCredential {
  final ChainedTokenCredential chainedTokenCredential;

  DefaultAzureCredential({super.logger})
      : chainedTokenCredential = ChainedTokenCredential(
          credentials: [
            ManagedIdentityCredential2019(logger: logger),
            ManagedIdentityCredential2017(logger: logger),
            AzureCliCredential(logger: logger),
          ],
        );

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    return chainedTokenCredential.getToken(options: options);
  }
}
