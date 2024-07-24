import 'dart:io';

import 'package:azure_identity/azure_identity.dart';
import 'package:jose/jose.dart';
import 'package:talker/talker.dart';

/// This class implements DefaultAzureCredential by leveraging an external
/// binary. The external binary needs to accept the list of scopes as command
/// line parameters and return the JWT as string via stdout.
/// This is not particularly efficient but service-to-service auth only needs
/// be done rarely (once every 24h when deployed, once every 60 minutes for
/// local debugging). The first request after the token timed out will probably
/// suffer from an additional delay of about 2s while the token is requested.
class BridgedDefaultAzureCredential implements TokenCredential {
  /// Location of the native binary that implements DefaultAzureCredential
  final String defaultAzureCredentialBinary;

  Talker? logger;

  BridgedDefaultAzureCredential({
    this.defaultAzureCredentialBinary = '/app/bin/fetch_token',
    this.logger,
  }) {
    if (!File(defaultAzureCredentialBinary).existsSync()) {
      throw Exception('fetch_token binary not found.');
    }
  }

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    final credentialBinary =
        await Process.run(defaultAzureCredentialBinary, options?.scopes ?? []);

    if (credentialBinary.exitCode != 0) {
      logger?.error(
          'Unable to acquire token: Bridge binary exited with an error code.');
      return null;
    }

    var tokenString = credentialBinary.stdout.toString().trim();

    if (!tokenString.startsWith("TOKEN=")) {
      logger?.error(
          'Unable to acquire token: Bridge binary returned an unexpected result');
      return null;
    }

    // strip leading 'TOKEN="' and trailing quote characters
    tokenString = tokenString.substring('TOKEN="'.length);
    tokenString = tokenString.substring(0, tokenString.length - 1);

    try {
      final jwt = JsonWebToken.unverified(tokenString);
      final expiry = jwt.claims.expiry;
      if (expiry == null) {
        logger?.error(
            'Unable to acquire token: Token does not contain expiration');
        return null;
      }

      return AccessToken(
          token: tokenString,
          expiresOnTimestamp: expiry.millisecondsSinceEpoch);
    } catch (e) {
      logger?.error('Unable to acquire token: Failed to decode token string');
      return null;
    }
  }
}
