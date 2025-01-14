import {generatePrivateKey, generateSeedPhrase, toPublicKey,credentialToAddress } from "npm:@lucid-evolution/utils";
import {Lucid, Blockfrost, Credential} from "npm:@lucid-evolution/lucid";
import * as CML from "npm:@anastasia-labs/cardano-multiplatform-lib-nodejs";
import {netid} from "./settings.ts";

const lucid = await Lucid(new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", Deno.env.get("BLOCKFROST_PROJECT_ID"),),netid);


// Generate a new private key
const privateKey01 = generatePrivateKey();
const publicKey01 = toPublicKey(privateKey01);
const address01 = await lucid.selectWallet.fromPrivateKey(privateKey01);

// Generate a private keyout of a seed phrase
const seedPhrase02 = generateSeedPhrase();
const privateKey02 = generatePrivateKey(seedPhrase02);

const publicKey02 = toPublicKey(privateKey02);
// const pkh = toPublicKey(privateKey).hash();   

// const paymentCredential: Credential = {
//     type: "Key",
//     hash: pkh
// };
// const address = credentialToAddress("Preview", paymentCredential,);
console.log ("----- Address 01 -----");

console.log("Private Key: ", privateKey01);
console.log("Public Key: ", publicKey01);
console.log("Address: ", address01);

console.log ("----- Address 02 (from SeedPhrase) -----");
console.log("Seed Phrase: ", seedPhrase02);
console.log("Private Key: ", privateKey02);
console.log("Public Key: ", publicKey02);


//console.log("Public Key Hash: ", pkh);
// console.log("Address: ", address);
