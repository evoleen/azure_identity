import 'package:azure_identity/azure_identity.dart';

Future<void> main() async {
  // create instance of DefaultAzureCredential using the bridge binary
  final defaultAzureCredential = DefaultAzureCredential(
    logger: print,
  );

  // initialize credential manager
  final credentialManager = CredentialManager(
    credential: defaultAzureCredential,
    options: GetTokenOptions(
      scopes: ['https://myserver.fhir.azurehealthcareapis.com/'],
    ),
  );

  final token = await credentialManager.getAccessToken();

  print(token?.token);
}
