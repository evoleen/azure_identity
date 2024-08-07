import 'package:azure_identity/azure_identity.dart';

/// Implements a credential that allows fetching a credential through a list
/// of other credential providers. The class will try all providers in sequence
/// and returns the first token it can acquire. This is useful to create
/// a unified implementation that works without changes in local development
/// environments and in production environments, or if the authentication method
/// is not fully known.
class ChainedTokenCredential extends TokenCredential {
  final List<TokenCredential> credentials;

  const ChainedTokenCredential({required this.credentials, super.logger});

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    for (final credential in credentials) {
      final accessToken = await credential.getToken(options: options);

      if (accessToken != null) {
        return accessToken;
      }
    }

    return null;
  }
}
