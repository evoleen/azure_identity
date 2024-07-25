import { DefaultAzureCredential } from "@azure/identity"

const args = process.argv

// remove program name from args
args.shift();
args.shift();

// Azure SDK clients accept the credential as a parameter
const credential = new DefaultAzureCredential()
const token = await credential.getToken(args)

console.log('TOKEN="' + token.token + '"')

// needed for bun to really terminate, otherwise hangs here
process.exit()
