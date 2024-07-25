import 'package:azure_identity/azure_identity.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  // initialize DefaultAzureCredential with external token binary
  final credentialManager = CredentialManager(
    credential: BridgedDefaultAzureCredential(
      logger: Talker(),
    ),
    options: GetTokenOptions(
      scopes: [
        'https://kimdevworkspace-kim-data.fhir.azurehealthcareapis.com/'
      ],
    ),
  );

  final token = await credentialManager.getAccessToken();

  print(token?.token);
}
