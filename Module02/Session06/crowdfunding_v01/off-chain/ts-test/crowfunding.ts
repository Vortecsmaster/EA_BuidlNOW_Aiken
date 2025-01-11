import { Lucid, Blockfrost, SpendingValidator } from "https://deno.land/x/lucid@0.8.3/mod.ts";
import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";
import test01_signingKey from "../../../Wallets/Adr11skey.json" with {type: 'json'};

const lucid = await Lucid.new(
    new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", Deno.env.get("BLOCKFROST_PROJECT_ID")
    ),
    "Preview"
);

 
// Alternative, generate new private keys with Lucid
// const ourPrivateKey = lucid.utils.generatePrivateKey();
// await Deno.writeTextFile("OurAddress.skey", ourPrivateKey);


//read private key from file imported from json
const address11 = await lucid
  .selectWalletFromPrivateKey(test01_signingKey.cborHex)
  .wallet.address();
await Deno.writeTextFile("our.addr", address11);
 
//read validator from blueprint json file created with aiken

const validator = await readValidator();

async function readValidator(): Promise<SpendingValidator> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validator[0];
  return {
    type: "PlutusV2",
    script: toHex(cbor.encode(fromHex(validator.compiledCode)))
  };
}