import 'dart:convert';
import 'dart:io';

import 'package:azure_identity/src/token_credential.dart';

/// Attempts to acquire a token through running Azure CLI. Primarily useful
/// in development settings where the user authenticated through `az login`
/// has an IAM privilege with the target service.
class AzureCliCredential extends TokenCredential {
  final String _azureCliPath;

  AzureCliCredential({super.logger}) : _azureCliPath = _findAzureCliPath();

  /// Finds the path to the Azure CLI executable. The heuristic is necessary
  /// because a natively compiled binary embedding this package may not have
  /// access to the PATH environment variable.
  static String _findAzureCliPath() {
    final possiblePaths = [
      // macOS / Linux paths
      '/bin/az',
      '/usr/bin/az',
      '/usr/local/bin/az',
      '/opt/homebrew/bin/az',
      // Windows paths
      '${Platform.environment['LOCALAPPDATA']}\\Programs\\Python\\Python39\\Scripts\\az.cmd',
      '${Platform.environment['LOCALAPPDATA']}\\Programs\\Python\\Python38\\Scripts\\az.cmd',
      '${Platform.environment['LOCALAPPDATA']}\\Programs\\Python\\Python37\\Scripts\\az.cmd',
      '${Platform.environment['PROGRAMFILES']}\\Azure CLI\\az.exe',
      '${Platform.environment['PROGRAMFILES']}\\Microsoft SDKs\\Azure\\CLI2\\wbin\\az.cmd',
    ];

    for (final path in possiblePaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }

    // If not found in specific locations, return 'az' to let the system PATH handle it
    return 'az';
  }

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    if (options == null || options.scopes.isEmpty) {
      return null;
    }

    final resource = options.scopes.first;

    try {
      final tokenProcessResult = await Process.run(
        _azureCliPath,
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
