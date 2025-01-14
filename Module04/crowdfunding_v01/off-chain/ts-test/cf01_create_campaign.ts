import {Blockfrost,
        Lucid,
        LucidEvolution,
        SpendingValidator,
        generatePrivateKey,
        fromHex,
        Credential,
        credentialToAddress,
        applyDoubleCborEncoding,
        validatorToAddress,
        Constr,
        Data,
        fromText } from "npm:@lucid-evolution/lucid";

import bob_signingKey from "/home/cardano/Dev/Wallets/Bob_skey.json" with {type: 'json'};
import adr08_signingKey from "/home/cardano/Dev/Wallets/Adr08_skey.json" with {type: 'json'};
import {networkConfig} from "./settings.ts"
import { Result } from "./types.ts";

const project_path = "/home/cardano/Dev/CREOW/crowdfunding_v01";

console.log("Network: " + networkConfig.network);
console.log("BlockfrostKEY: " + networkConfig.blockfrostAPIkey);
console.log("BlockfrostURL: " + networkConfig.blockfrostAPI);

const lucid = await Lucid(new Blockfrost(networkConfig.blockfrostURL, networkConfig.blockfrostAPIkey), networkConfig.network);

const bobPaymentCredential: Credential = {
  type: "Key",
  hash: "2070f8488dd696b78a5f23e38d273550e43660526c4b19cba733b488"  //taken from cardano-cli generated verification key hash
};

const bobStakeCredential: Credential = {
    type: "Key",
    hash: "8662fe85a22159022d71aebcf4342bcafaa6ede0df2e486a4e751e8e" // taken from cardano-cli generated stake verification key hash
};

const bobSigningkey = bob_signingKey.ed25519;
const adr08Signingkey = adr08_signingKey.ed25519;

console.log("bob sk: " + bobSigningkey);
console.log("adr08 sk: " + adr08Signingkey);

lucid.selectWallet.fromPrivateKey(bobSigningkey);
const bobAddress = await lucid.wallet().address();
console.log("Address: " + bobAddress);

//read validator from blueprint json file created with aiken

 const validator = await readValidator();

 async function readValidator(): Promise<SpendingValidator> {
    const validator = JSON.parse(await Deno.readTextFile("/home/cardano/Dev/EA_DIY_Crowdfunding/crowdfunding_v01/plutus.json")).validators[0];
   return {
    type: "PlutusV3",
    script: applyDoubleCborEncoding(validator.compiledCode)
  };
}

const campaignsAddress = validatorToAddress(networkConfig.network, validator,bobStakeCredential); //Bob's staking credential

console.log(campaignsAddress);

// Create a campaign
const campaign = async (): Promise<Result<string>> => { 
   try {
  
     if (!lucid) throw "Uninitialized Lucid";
     if (!bobAddress) throw "Non defined Bob's address";
     if (!campaignsAddress) throw "Non defined script address";
 
    const timing = Date.now()
    const deadline = BigInt(timing + 1000 * 60 * 5);
    console.log("Deadline: " + deadline);
    const datum = Data.to(new Constr(0, [7n,
        fromText("Demo Campaign 8"),
        77000000n,
        "8060ec982b6188709f63821bece0be6081c74cf13807d52e4b4a108d",
        "",
        0n,
        deadline,
        0n]));

//   CFDatum -  
//   campaign_id: Int,
//   title: ByteArray,
//   goal: Int,
//   creator: VerificationKeyHash,
//   backer: VerificationKeyHash,
//   amount: Int,
//   deadline: Int,
//   current_funds: Int,
// }

    const tx = await lucid
       .newTx()
       
       .pay.ToContract(
          campaignsAddress,
          {kind: "inline" , value: datum},
          {lovelace: 2200000n}
        )
       .complete();

    const signedTx = await tx.sign.withWallet().complete();
    const txHash = await signedTx.submit();

     console.log("TODO BIEN!")
     return { type: "ok", data: txHash };
    }
   catch (error) {
     console.log("Error: " + error);
     if (error instanceof Error) return { type: "error", error: error };
     return { type: "error", error: new Error(`${JSON.stringify(error)}`) };
   }
 };

 let txHash = await campaign()
 console.log("Realized Tx: " + txHash.data);