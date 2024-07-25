import '../lib/azure_identity.dart';

Future<void> main() async {
  final credential = BridgedDefaultAzureCredential();
  final token = await credential.getToken();
  print(token);
}
