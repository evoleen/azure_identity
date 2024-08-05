import 'package:azure_identity/src/chained_token_credential.dart';
import 'package:azure_identity/src/managed_identity_credential_2017.dart';
import 'package:azure_identity/src/managed_identity_credential_2019.dart';
import 'package:azure_identity/src/token_credential.dart';

/// Stripped down version of the Azure SDK's DefaultAzureCredential.
/// Will attempt the following authentication methods in sequence:
/// - Managed Identity 2019
/// - Managed Identity 2017
/// - Azure CLI
/// The original Azure SDK offers a few more methods in DefaultAzureCredential
/// which are not implemented in this package yet. However, the current methods
/// should provide a single token source for 75% of all use cases in
/// development and managed deployment scenarios.
class DefaultAzureCredential implements TokenCredential {
  final chainedTokenCredential = ChainedTokenCredential(
    credentials: [
      ManagedIdentityCredential2019(),
      ManagedIdentityCredential2017(),
    ],
  );

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    return chainedTokenCredential.getToken(options: options);
  }
}
