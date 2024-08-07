import 'package:azure_identity/azure_identity.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  final logger = Talker();

  // create instance of DefaultAzureCredential using the bridge binary
  final defaultAzureCredential = DefaultAzureCredential(
    logger: logger.info,
  );

  // initialize credential manager
  final credentialManager = CredentialManager(
    credential: defaultAzureCredential,
    options: GetTokenOptions(
      scopes: [
        'https://kimdevworkspace-kim-data.fhir.azurehealthcareapis.com/'
      ],
    ),
  );

  final token = await credentialManager.getAccessToken();

  print(token?.token);
}
