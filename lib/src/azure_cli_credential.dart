import 'dart:convert';
import 'dart:io';

import 'package:azure_identity/src/token_credential.dart';

/// Attempts to acquire a token through running Azure CLI. Primarily useful
/// in development settings where the user authenticated through `az login`
/// has an IAM privilege with the target service.
class AzureCliCredential implements TokenCredential {
  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    if (options == null || options.scopes.isEmpty) {
      return null;
    }

    final resource = options.scopes.first;

    final tokenProcessResult = await Process.run(
      'az',
      [
        'account',
        'get-access-token',
        '--resource=$resource',
      ],
    );

    if (tokenProcessResult.exitCode != 0) {
      return null;
    }

    final tokenOutput = jsonDecode(tokenProcessResult.stdout.toString());

    return AccessToken(
      token: tokenOutput['accessToken'],
      expiresOnTimestamp: int.parse(tokenOutput['expires_on']) * 1000,
    );
  }
}
