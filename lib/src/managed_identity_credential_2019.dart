import 'dart:io';

import 'package:azure_identity/azure_identity.dart';
import 'package:dio/dio.dart';

/// Acquires a token through the Azure Managed Identity service. Requires the
/// process to be executed inside Azure and with "managed identity" enabled.
/// Uses the 2019 API.
class ManagedIdentityCredential2019 extends TokenCredential {
  final Dio _dio;

  static const String apiVersion = '2019-08-01';

  /// Constructs a new managed identity credential. If [dio] is passed, will
  /// use the externally configured instance of the Dio client. Otherwise
  /// will instantiate an instance with default options.
  ManagedIdentityCredential2019({Dio? dio, super.logger}) : _dio = dio ?? Dio();

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    if (options == null || options.scopes.isEmpty) {
      logger
          ?.call('Cannot fetch token for Managed Identity 2019 without scope.');
      return null;
    }

    final resource = options.scopes[0];

    final identityEndpoint = Platform.environment['IDENTITY_ENDPOINT'] ?? '';
    final identityHeader = Platform.environment['IDENTITY_HEADER'] ?? '';

    if (identityEndpoint.isEmpty || identityHeader.isEmpty) {
      logger?.call(
          'Required environment variables for Managed Identity 2019 not found.');
      return null;
    }

    try {
      final identityEndpointUri = Uri.parse(identityEndpoint);
      final requestUri = identityEndpointUri
          .resolve('?resource=$resource&api-version=$apiVersion');

      final tokenResponse = await _dio.getUri(
        requestUri,
        options: Options(
          headers: {
            'X-IDENTITY-HEADER': identityHeader,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (tokenResponse.statusCode != 200) {
        logger?.call(
            'Fetch token request for Managed Identity 2019 resulted in HTTP status code ${tokenResponse.statusCode}');
        return null;
      }

      final tokenJson = tokenResponse.data;

      return AccessToken(
        token: tokenJson['access_token'],
        expiresOnTimestamp: int.parse(tokenJson['expires_on']) * 1000,
      );
    } catch (e) {
      logger?.call(
          'Fetch token request for Managed Identity 2019 caused exception: $e');
    }

    return null;
  }
}
