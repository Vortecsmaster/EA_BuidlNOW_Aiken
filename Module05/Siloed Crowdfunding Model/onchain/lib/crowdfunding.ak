use aiken/collection/dict
use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use cardano/address.{Address, Script, VerificationKey}
use cardano/assets.{Lovelace, PolicyId}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction,
}
use config
use crowdfunding/types.{
  BackerDatum, CampaignAction, CampaignDatum, Cancel, Cancelled, Finish,
  Finished, Refund, Running,
}
use crowdfunding/utils
use time_util/unsafe/bound as unsafe_unwrap

/// Validates the following action:
/// - Create campaign
pub fn validate_mint_campaign(
  platform _platform: VerificationKeyHash,
  creator: VerificationKeyHash,
  nonce: OutputReference,
  campaign_datum: CampaignDatum,
  self_script: PolicyId,
  tx: Transaction,
) -> Bool {
  tx |> validate_create_campaign(self_script, campaign_datum, nonce, creator)
}

/// Validates the following actions:
/// - Cancel campaign
/// - Finish campaign
/// - Refund campaign
/// - When there is no datum
pub fn validate_spend_campaign(
  platform: VerificationKeyHash,
  creator _creator: VerificationKeyHash,
  nonce _nonce: OutputReference,
  datum: Option<Data>,
  campaign_action: CampaignAction,
  o_ref: OutputReference,
  tx: Transaction,
) -> Bool {
  expect Some(Input { output: Output { address, .. }, .. }) =
    tx.inputs |> transaction.find_input(o_ref)
  expect Script(self_script) = address.payment_credential

  when (datum, campaign_action) is {
    // Cancel campaign:
    (Some(current_datum), Cancel) ->
      if current_datum is campaign_datum: CampaignDatum {
        tx |> validate_cancel_campaign(self_script, campaign_datum, platform)
      } else {
        fail @"Invalid Cancel Datum Type! Must be CampaignDatum"
      }

    // Finish campaign:
    (Some(current_datum), Finish) ->
      tx |> validate_finish_campaign(self_script, current_datum, platform)

    // Refund campaign:
    (Some(current_datum), Refund) ->
      if current_datum is backer_datum: BackerDatum {
        tx |> validate_refund_support(self_script, backer_datum)
      } else {
        fail @"Invalid Refund Datum Type! Must be BackerDatum"
      }

    // NoDatum etc:
    _ -> {
      expect !is_running_campaign(tx.reference_inputs, self_script)
      tx |> must_be_signed_by(platform)
    }
  }
}

// ## Validation Functions

fn validate_create_campaign(
  tx: Transaction,
  self_script: PolicyId,
  campaign_datum: CampaignDatum,
  nonce: OutputReference,
  creator: VerificationKeyHash,
) -> Bool {
  expect CampaignDatum { goal, deadline, creator: (pkh, _), state: Running, .. } =
    campaign_datum
  expect creator == pkh
  expect goal > 0
  expect unsafe_unwrap.finite_start_of(tx.validity_range) < deadline
  and {
    must_consume_creator_nonce(tx, creator, nonce)?,
    must_mint_state_token(tx, self_script)?,
    must_send_state_token(tx, self_script, campaign_datum)?,
  }
}

fn validate_cancel_campaign(
  tx: Transaction,
  self_script: PolicyId,
  campaign_datum: CampaignDatum,
  platform: VerificationKeyHash,
) -> Bool {
  // platform can only cancel after deadline, creator can cancel at anytime
  let is_signed_by_platform = tx |> must_be_signed_by(platform)
  and {
    if is_signed_by_platform? {
      must_be_after_deadline(tx, campaign_datum.deadline)?
    } else {
      must_be_signed_by(tx, campaign_datum.creator.1st)?
    },
    is_running_campaign(tx.inputs, self_script)?,
    must_send_state_token(
      tx,
      self_script,
      with_datum: CampaignDatum { ..campaign_datum, state: Cancelled },
    )?,
  }
}

fn validate_finish_campaign(
  tx: Transaction,
  self_script: PolicyId,
  current_datum: Data,
  platform: VerificationKeyHash,
) -> Bool {
  if current_datum is campaign_datum: CampaignDatum {
    // platform can only finish after deadline, creator can finish early whevener the goal is reached
    let is_signed_by_platform = tx |> must_be_signed_by(platform)
    and {
      if is_signed_by_platform? {
        must_be_after_deadline(tx, campaign_datum.deadline)?
      } else {
        must_be_signed_by(tx, campaign_datum.creator.1st)?
      },
      is_running_campaign(tx.inputs, self_script)?,
      must_send_state_token(
        tx,
        self_script,
        with_datum: CampaignDatum { ..campaign_datum, state: Finished },
      )?,
      must_reach_goal_and_send_to_creator(
        tx,
        self_script,
        campaign_datum.goal,
        campaign_datum.creator,
      )?,
    }
  } else if current_datum is BackerDatum {
    // must consume state token UTxO successfully
    is_running_campaign(tx.inputs, self_script)?
  } else {
    fail @"Invalid Finish Datum Type!"
  }
}

fn validate_refund_support(
  tx: Transaction,
  self_script: PolicyId,
  backer_datum: BackerDatum,
) -> Bool {
  expect !is_running_campaign(tx.reference_inputs, self_script)
  must_refund(tx, self_script, backer_datum)?
}

// ## Helper Functions

fn is_running_campaign(tx_inputs: List<Input>, self_script: PolicyId) -> Bool {
  // must consume/refer state token UTxO
  expect Some(Input { output: Output { datum, .. }, .. }) = {
    let input <- list.find(tx_inputs)
    assets.quantity_of(input.output.value, self_script, config.state_token) == 1
  }

  // must be campaign inline datum
  expect InlineDatum(campaign_datum) = datum
  expect CampaignDatum { state, .. } = campaign_datum

  state == Running
}

fn must_be_signed_by(tx: Transaction, signer: VerificationKeyHash) -> Bool {
  // just expect 1 signer
  ([signer] == tx.extra_signatories)?
}

fn must_be_after_deadline(tx: Transaction, deadline: Int) -> Bool {
  // tx validFrom is after or at deadline
  (unsafe_unwrap.finite_start_of(tx.validity_range) >= deadline)?
}

fn must_reach_goal_and_send_to_creator(
  tx: Transaction,
  self_script: PolicyId,
  goal: Lovelace,
  (creator_pkh, creator_skh),
) {
  let self_address = Address(Script(self_script), None)

  // helper fn to sum backer supports from TxInputs
  let sum_support =
    fn(sum, Input { output: Output { address, datum, value, .. }, .. }) {
      if address == self_address {
        when datum is {
          InlineDatum(input_datum) ->
            if input_datum is BackerDatum {
              assets.lovelace_of(value) + sum
            } else {
              sum
            }
          _ -> sum
        }
      } else {
        sum
      }
    }
  // backer supports must reach goal (sum_support >= goal)?
  let supports = tx.inputs |> list.reduce(0, sum_support)
  expect supports >= goal

  let creator_address = (creator_pkh, creator_skh) |> utils.address_from_tuple

  // helper fn to sum TxOutputs Lovelace sent to creator
  let sum_creator =
    fn(sum, Output { address, value, .. }) {
      if address == creator_address {
        assets.lovelace_of(value) + sum
      } else {
        sum
      }
    }
  // creator must receive backer supports (sum_creator >= sum_support)?
  (list.reduce(tx.outputs, 0, sum_creator) >= supports)?
}

fn must_refund(
  tx: Transaction,
  self_script: PolicyId,
  backer_datum: BackerDatum,
) {
  let backer_datum_data: Data = backer_datum

  // collect input backer support lovelaces from self address
  let self_address = Address(Script(self_script), None)
  let sum_input =
    fn(sum, Input { output: Output { address, datum, value, .. }, .. }) {
      if address == self_address {
        when datum is {
          InlineDatum(input_datum) ->
            if input_datum == backer_datum_data {
              assets.lovelace_of(value) + sum
            } else {
              sum
            }
          _ -> sum
        }
      } else {
        sum
      }
    }
  let input_lovelace = list.reduce(tx.inputs, 0, sum_input)

  // collect output lovelaces to backer address
  let backer_address = utils.address_from_tuple(backer_datum)
  let sum_output =
    fn(sum, Output { address, value, .. }) {
      if address == backer_address {
        assets.lovelace_of(value) + sum
      } else {
        sum
      }
    }
  let output_lovelace = list.reduce(tx.outputs, 0, sum_output)

  (output_lovelace >= input_lovelace)?
}

fn must_send_state_token(
  tx: Transaction,
  self_script: PolicyId,
  with_datum: CampaignDatum,
) -> Bool {
  let with_datum_data: Data = with_datum
  let self_address = address.from_script(self_script)
  let Output { address, datum, value, .. } <- list.any(tx.outputs)

  when datum is {
    // only handle inline datum
    InlineDatum(output_datum) -> and {
        address == self_address,
        output_datum == with_datum_data,
        assets.quantity_of(value, self_script, config.state_token) == 1,
      }

    // does not handle non-inline datum
    _ -> False
  }
}

// ### Campaign Creation: "STATE_TOKEN" NFT Minting

fn must_mint_state_token(tx: Transaction, self_script: PolicyId) -> Bool {
  let minted_tokens = tx.mint |> assets.tokens(self_script) |> dict.to_pairs()

  // restrict minting to 1 quantity and 1 asset name with self Policy ID
  ([Pair(config.state_token, 1)] == minted_tokens)?
}

fn must_consume_creator_nonce(
  tx: Transaction,
  creator: VerificationKeyHash,
  nonce: OutputReference,
) -> Bool {
  let Input(
    output_reference,
    Output { address: Address { payment_credential, .. }, .. },
  ) <- list.any(tx.inputs)

  // the nonce utxo must come from the campaign creator
  and {
    output_reference == nonce,
    VerificationKey(creator) == payment_credential,
  }
}
