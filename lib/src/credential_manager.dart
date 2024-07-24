import 'package:azure_identity/azure_identity.dart';

/// Dynamically requests tokens from registered credential provider as
/// necessary. Offloads the need to cache the token and manage time-out events.
class CredentialManager {
  /// Credential provider used to retrieve tokens
  final TokenCredential credential;

  /// Options needed to fetch the token
  final GetTokenOptions options;

  /// The current token. [null] if no token is available.
  AccessToken? currentToken;

  CredentialManager({required this.credential, required this.options});

  Future<AccessToken?> getAccessToken() async {
    final token = currentToken;

    if (token == null ||
        token.expiresOnTimestamp <=
            DateTime.timestamp().millisecondsSinceEpoch) {
      // no token availabl or previous token expired, fetch new one
      currentToken = await credential.getToken(options: options);
    }

    return currentToken;
  }
}
