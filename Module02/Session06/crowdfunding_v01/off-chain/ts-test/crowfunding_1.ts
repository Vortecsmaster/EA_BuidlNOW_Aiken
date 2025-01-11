// import { Lucid, Blockfrost, SpendingValidator, fromHex, toHex, Credential, credentialToAddress } from "npm:@lucid-evolution/lucid";
import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";
import {Blockfrost, Data, Lucid, Validator, validatorToAddress,Credential} from "npm:@lucid-evolution/lucid";
import {credentialToAddress} from "npm:@lucid-evolution/utils";
import test01_signingKey from "../../../Wallets/Adr11skey.json" with {type: 'json'};
import * from "./settings.ts";



const lucid = await Lucid(new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", Deno.env.get("BLOCKFROST_PROJECT_ID"),),netid);

const paymentCredential: Credential = {
     type: "Key",
     hash: "2070f8488dd696b78a5f23e38d273550e43660526c4b19cba733b488"  //taken from cardano-cli generated verification key hash
 };

const stakeCredential: Credential = {
       type: "Key",
       hash: "8662fe85a22159022d71aebcf4342bcafaa6ede0df2e486a4e751e8e" // taken from cardano-cli generated stake verification key hash
   };
const address11 = await credentialToAddress(netid,paymentCredential, stakeCredential);
await Deno.writeTextFile("our.addr", address11);

