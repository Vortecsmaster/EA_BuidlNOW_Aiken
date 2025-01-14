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
        fromText,
        PROTOCOL_PARAMETERS_DEFAULT } from "npm:@lucid-evolution/lucid";
import bob_signingKey from "/home/cardano/Dev/Wallets/Bob_skey.json" with {type: 'json'};
import adr08_signingKey from "/home/cardano/Dev/Wallets/Adr08_skey.json" with {type: 'json'};
import {networkConfig} from "./settings.ts"
import { Result } from "./types.ts";

const project_path = "/home/cardano/Dev/CREOW/crowdfunding_v01";

const lucid = await Lucid(new Blockfrost(
                            networkConfig.blockfrostURL, 
                            networkConfig.blockfrostAPIkey,
                            
                          ),
                          networkConfig.network,
                          {presetProtocolParameteres: PROTOCOL_PARAMETERS_DEFAULT}
                        );

const bobPaymentCredential: Credential = {
  type: "Key",
  hash: "2070f8488dd696b78a5f23e38d273550e43660526c4b19cba733b488"  //taken from cardano-cli generated verification key hash
};

const bobStakeCredential: Credential = {
    type: "Key",
    hash: "8662fe85a22159022d71aebcf4342bcafaa6ede0df2e486a4e751e8e" // taken from cardano-cli generated stake verification key hash
};

const bobSigningkey = bob_signingKey.ed25519;

console.log("bob sk: " + bobSigningkey);
console.log("adr08 sk: " + adr08_signingKey.ed25519);

lucid.selectWallet.fromPrivateKey(adr08_signingKey.ed25519);
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

const campaignsAddress = validatorToAddress(networkConfig.network, validator, bobStakeCredential); //Bob's staking credential

console.log("Validator Address: " + campaignsAddress);

// Create a campaign
const cancel_campaign = async (): Promise<Result<string>> => { 
  try {
  
    if (!lucid) throw "Uninitialized Lucid";
    if (!bobAddress) throw "Non defined Bob's address";
    if (!campaignsAddress) throw "Non defined script address";
 
    const DatumSchema = Data.Object({
      campaign_id: Data.Integer(),
      title: Data.Bytes(),
      goal: Data.Integer(),
      creator: Data.Bytes(),
      backer: Data.Bytes(),
      amount: Data.Integer(),
      deadline: Data.Integer(),
      current_funds: Data.Integer(),
    })
    type CFDatum = Data.Static<typeof DatumSchema>;
    const CFDatum = DatumSchema as unknown as CFDatum;

    const campaigns_utxos = await lucid.utxosAt(campaignsAddress);
    const campaign_utxo = campaigns_utxos.find((utxo) => {
      if (utxo.datum) {
        // console.log("Datum: " + utxo.datum);
        const dat = Data.from(utxo.datum, CFDatum)
        console.log(dat.campaign_id)
        console.log(dat.deadline)
        return dat.deadline === 1731883588000n}
    });

 
const redeemer = Data.to(new Constr(0, [1n,0n,0n,""]));

console.log("Redeemer: " + Data.from(redeemer));


//  pub type CFredeemer {
//   campaign_id: Int,
//   action: Action,
//   amount: Int,
//   backer: VerificationKeyHash,
// }

 console.log("Campaign UTXO: " + campaign_utxo);
 console.log("------------------------------------------------------------------------------------------------------------------------");
    const tx = await lucid
      .newTx()
      .collectFrom([campaign_utxo], redeemer)
      .attach.SpendingValidator(validator)
      .pay.ToAddress(bobAddress, {lovelace: 2000000n})
      .addSigner(bobAddress)
      .validTo(Date.now())
      .complete({});

    // console.log("Tx: " + tx);
    const signedTx = await tx.sign.withWallet().complete();
    const txHash = await signedTx.submit();

    console.log("TODO BIEN!")
    return { type: "ok", data: txHash };
    //   return { type: "ok", data: "tx Built!" };
    }
   catch (error) {
     console.log("Error: " + error);
     if (error instanceof Error) return { type: "error", error: error };
     return { type: "error", error: new Error(`${JSON.stringify(error)}`) };
    }
  };

let txHash = await cancel_campaign()
console.log("Realized Tx: " + txHash.data);