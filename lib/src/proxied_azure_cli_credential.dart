import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:azure_identity/src/token_credential.dart';

/// Attempts to acquire a token through a proxied instance of Azure CLI.
/// The output of Azure CLI is expected at http://localhost:8181 by default
/// and can be overridden by setting the environment variable
/// AZURE_CLI_PROXY_HOST. This token is intended to be used in development
/// settings where the application is running locally inside a Docker container
/// but does not have access to Azure CLI inside the container.
class ProxiedAzureCliCredential extends TokenCredential {
  ProxiedAzureCliCredential({super.logger});

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    if (options == null || options.scopes.isEmpty) {
      return null;
    }

    final resource = options.scopes.first;

    try {
      var proxyHost = Platform.environment['AZURE_CLI_PROXY_HOST'];
      proxyHost ??= 'http://host.docker.internal:8181/';

      proxyHost = '$proxyHost?resource=$resource';

      final response = await http.get(Uri.parse(proxyHost));
      if (response.statusCode != 200) {
        logger?.call('Unable to access token proxy at http://localhost:8181.');
        return null;
      }

      final tokenOutput = jsonDecode(response.body);

      return AccessToken(
        token: tokenOutput['accessToken'],
        expiresOnTimestamp: tokenOutput['expires_on'] * 1000,
      );
    } catch (e) {
      logger?.call(
          'Tried to access token proxy but received invalid response: $e');
      return null;
    }
  }
}
