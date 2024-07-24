/// Represents a credential capable of providing an authentication token.
abstract class TokenCredential {
  /// Gets the token provided by this credential.
  ///
  /// This method is called automatically by Azure SDK client libraries. You may call this method
  /// directly, but you must also handle token caching and token refreshing.
  ///
  /// [scopes]  - The list of scopes for which the token will have access.
  /// [options] - The options used to configure any requests this
  ///             TokenCredential implementation might make.
  Future<AccessToken?> getToken({
    GetTokenOptions? options,
  });
}

/// Defines options for TokenCredential.getToken.
class GetTokenOptions {
  final List<String> scopes;

  /// Claim details to perform the Continuous Access Evaluation authentication flow
  String? claims;

  /// Indicates whether to enable the Continuous Access Evaluation authentication flow
  final bool enableCae;

  /// Allows specifying a tenantId. Useful to handle challenges that provide tenant Id hints.
  String? tenantId;

  GetTokenOptions(
      {required this.scopes,
      this.claims,
      this.enableCae = false,
      this.tenantId});
}

/// Represents an access token with an expiration time.
class AccessToken {
  /// The access token returned by the authentication service.
  final String token;

  /// The access token's expiration timestamp in milliseconds, UNIX epoch time.
  final int expiresOnTimestamp;

  const AccessToken({required this.token, required this.expiresOnTimestamp});
}
