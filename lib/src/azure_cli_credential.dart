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

  /// Determines whether the given [value] is a v2 OAuth scope or a v1
  /// resource URI.
  ///
  /// A v2 scope contains a permission suffix appended to the base URI
  /// (e.g. `api://my-app/.default`, `api://my-app/access`,
  /// `https://graph.microsoft.com/User.Read`).
  ///
  /// A v1 resource is a bare URI with no meaningful path segments
  /// (e.g. `api://my-app`, `https://management.azure.com/`).
  ///
  /// The distinction matters because Azure CLI's `az account get-access-token`
  /// requires `--scope` for v2 scopes and `--resource` for v1 resources.
  /// Passing a v2 scope to `--resource` fails because Azure CLI treats the
  /// entire string (including the suffix) as a literal resource name.
  static bool _isV2Scope(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    // A v2 scope has non-empty path segments (e.g. '.default' or 'access').
    // A bare resource URI has no path or only a trailing slash (empty segment).
    final hasPathSegments =
        uri.pathSegments.any((segment) => segment.isNotEmpty);
    return hasPathSegments;
  }

  @override
  Future<AccessToken?> getToken({GetTokenOptions? options}) async {
    if (options == null || options.scopes.isEmpty) {
      return null;
    }

    final value = options.scopes.first;
    final cliFlag = _isV2Scope(value) ? '--scope' : '--resource';

    try {
      final tokenProcessResult = await Process.run(
        _azureCliPath,
        [
          'account',
          'get-access-token',
          '$cliFlag=$value',
        ],
      );

      if (tokenProcessResult.exitCode != 0) {
        logger?.call(
            'AZ CLI returned error code ${tokenProcessResult.exitCode}. '
            'Command: $_azureCliPath account get-access-token $cliFlag=$value. '
            'stderr: ${tokenProcessResult.stderr}');
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
