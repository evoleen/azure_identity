import 'dart:convert';
import 'dart:io';

import 'package:azure_identity/src/token_credential.dart';

/// Attempts to acquire a token through running Azure CLI. Primarily useful
/// in development settings where the user authenticated through `az login`
/// has an IAM privilege with the target service.
class AzureCliCredential extends TokenCredential {
  AzureCliCredential({super.logger});

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    if (options == null || options.scopes.isEmpty) {
      return null;
    }

    final resource = options.scopes.first;

    try {
      final tokenProcessResult = await Process.run(
        'az',
        [
          'account',
          'get-access-token',
          '--resource=$resource',
        ],
      );

      if (tokenProcessResult.exitCode != 0) {
        logger?.call(
            'AZ CLI returned error code ${tokenProcessResult.exitCode}, either AZ CLI is not installed or "az login" needs to be run.');
        return null;
      }

      final tokenOutput = jsonDecode(tokenProcessResult.stdout.toString());

      return AccessToken(
        token: tokenOutput['accessToken'],
        expiresOnTimestamp: tokenOutput['expires_on'] * 1000,
      );
    } catch (e) {
      logger?.call('Unable to execute AZ CLI: $e');
      return null;
    }
  }
}
