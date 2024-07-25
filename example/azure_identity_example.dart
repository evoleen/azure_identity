import 'package:azure_identity/azure_identity.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  // create instance of DefaultAzureCredential using the bridge binary
  final bridgedDefaultAzureCredential =
      await BridgedDefaultAzureCredential.create(
    logger: Talker(),
  );

  // initialize credential manager
  final credentialManager = CredentialManager(
    credential: bridgedDefaultAzureCredential,
    options: GetTokenOptions(
      scopes: [
        'https://kimdevworkspace-kim-data.fhir.azurehealthcareapis.com/'
      ],
    ),
  );

  final token = await credentialManager.getAccessToken();

  print(token?.token);
}
