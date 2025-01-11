use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use cardano/transaction.{OutputReference, Transaction}
use cardano/assets.{PolicyId}

/// shorthand notation for custom types
/// the full version would have the explicit Data Constructor like
/// type Datum { Datum {...fields are the same...} }
pub type CFdatum {
  goal: Int,
  backer: VerificationKeyHash,
  deadline: Int,
}

/// Actions Enumerator
///  0 -> Cancel Campaign
///  1 -> Support Campaign
///  2 -> Claims
<<<<<<< Updated upstream
pub type CFredeemer =
=======
///
pub type Action =
>>>>>>> Stashed changes
  Int

///  0 -> Forge Campaign Token
///  1 -> Forge Backers Token
///  2 -> Burn Campaign Token
///  3 -> Burn Backer Token
pub type MintAction = Int

validator manage_campaign(campaign_id: Int, title: ByteArray, creator: VerificationKeyHash, appkey: VerificationKeyHash) {
  spend(
    datum: Option<CFdatum>,
    redeemer: CFredeemer,
    utxo: OutputReference,
    transaction: Transaction,
  ) {
    expect Some(datum) = datum
    expect must_spend_token(utxo, transaction)

    when redeemer is {
      0 -> cancel_campaign(
           datum,
           creator,
           transaction.extra_signatories,
         )

      1 -> support_campaign(
           datum,
           transaction.extra_signatories,
        )

<<<<<<< Updated upstream
      2 -> claims(datum, creator, transaction.extra_signatories)
=======
      1 ->
        support_campaign(
          datum,
          redeemer,
          utxo,
          transaction,
        )

      2 -> claims(datum, redeemer.campaign_id, transaction.extra_signatories)
>>>>>>> Stashed changes
      _ -> fail
    }
  }

  mint(redeemer: MintAction, policy: PolicyId , tx_info: Transaction) {
      when redeemer is {
          0 -> must_be_signed_by(appkey, tx_info.extra_signatories) && must_be_signed_by(creator, tx_info.extra_signatories)
          1 -> True
          2 -> True
          3 -> True
          _ -> False


      }
  }

  else(_) {
    fail
  }
}

fn must_spend_token(utxo: OutputReference, tx_info: Transaction) -> Bool {
  expect Some(own_input) = 
    tx_info.inputs
       |> transaction.find_input(utxo)

  let allOwnInputs =
      tx_info.inputs
        |> map(fn(i) { i.output })
        |> filter(fn(o) { o.address.payment_credential == ownHash })

  let allOwnOutputs =
      self.outputs |> filter(fn(o) { o.address.payment_credential == ownHash })

  expect Script(policy_id) = input.output.address.payment_credential
  trace @"PolicyID": policy_id
  expect [Pair(asset_name, amount)] =
    mint
      |> assets.tokens(policy_id)
      |> dict.to_pairs()
  trace @"Token": asset_name, amount
  (asset_name, amount)
}


/// Cancellation conditions
///  Datum.campaignId == Redeemer.campaignId
///  Datum.creator => Authorize transaction by signing it.
///  Datum.current_funds == 0
///  Datum.amount == 0
///
fn cancel_campaign(
  datum: CFdatum,
  creator: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool {
   datum.backer == "" && must_be_signed_by(
    creator,
    signatories,
  )
}



/// Update conditions
///    Datum.campaignId == Redeemer.campaignId
///    Datum.backer => Authorize his support by signing the transaction.
<<<<<<< Updated upstream
///
fn support_campaign(
  datum: CFdatum,
  signatories: List<VerificationKeyHash>,
) -> Bool {
   must_be_signed_by(
    datum.backer,
    signatories,
  )
=======
/// Redeemer include the supporter and amount.
/// Datum.current_funds must be equal to its input value plus the defined support value (CFredeemer.ammount).


fn support_campaign(datum: CFdatum, redeemer: CFredeemer, utxo: OutputReference, tx_info: Transaction) -> Bool {
  datum.campaign_id == redeemer.campaign_id && 
  output_datum_updated(datum, redeemer, utxo, tx_info) && 
  must_be_signed_by(redeemer.backer, tx_info.extra_signatories)


  // datum.campaign_id == campaign_id && must_be_signed_by(datum.backer, signatories)
>>>>>>> Stashed changes
}

/// Claims conditions
///   Datum.campaignId == Redeemer.campaignId
///   Datum.current_funds >= Datum.goal
///   Datum.creator => Authorize transaction by signingn it.
///
fn claims(
  datum: CFdatum,
  creator: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool { must_be_signed_by(
    creator,
    signatories,
  )
}

fn output_datum_updated(datum: CFdatum, redeemer: CFredeemer, utxo: OutputReference, tx_info: Transaction) -> Bool {
  let input_datum = complete_datum(datum,tx_info.datums)
  
}  

fn complete_datum(
  input_datum: CFDatum,
  datums: Dict<DataHash, Data>,
) -> (DataHash, Data) {
  expect Some(data_hash) = dict.find(datums, input_datum)

  let data_hash: DataHash = data_hash
  let data: Data = input_datum

  (data_hash, data)
}

fn updated_output(
  input_datum: (DataHash, Data),
  outputs: List<Output>,
  address: Address,
) -> Bool {
  let counter =
    list.count(
      outputs,
      fn(output) -> Bool {
        output.address == address && when output.datum is {
          NoDatum -> False
          DatumHash(datum_hash) -> datum_hash == input_datum.1st
          InlineDatum(datum_data) -> datum_data == input_datum.2nd
        }
      },
    )

  counter == 1
}




fn must_be_signed_by(
  signer: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  // The verificationKeyHash is the hash of the verification key of the signature
  list.has(signatories, signer)
}

// This contract is like swiss cheese, full of holes.