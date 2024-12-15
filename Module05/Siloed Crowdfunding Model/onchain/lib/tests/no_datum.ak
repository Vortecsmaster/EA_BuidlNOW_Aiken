use aiken/collection/list
use cardano/assets
use cardano/transaction.{InlineDatum, OutputReference}
use crowdfunding
use crowdfunding/types.{
  CampaignDatum, Cancel, Cancelled, Finish, Finished, Refund, Running,
}
use tests/constants.{
  campaign_address, campaign_nonce, campaign_state_o_ref, campaign_state_token,
  creator_address, creator_pkh, platform_address, platform_pkh,
}
use tx_util/builder/txn.{
  add_asset_to_tx_output, add_signatory, add_tx_input, add_tx_output,
  add_tx_ref_input, set_datum_of_tx_input, with_asset_of_tx_input,
}

// ## Positive Tests

test no_datum_positive_cancelled_campaign() {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Cancelled,
    }
  let campaign_datum: Data = campaign_state

  let no_datum_o_ref = OutputReference("NO_DATUM_OREF_TxHash", 0)

  let tx_ref_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input =
    txn.new_tx_input(no_datum_o_ref, campaign_address)
      |> with_asset_of_tx_input(assets.from_lovelace(500_000_000))

  let tx_output =
    txn.new_tx_output(platform_address)
      |> add_asset_to_tx_output(assets.from_lovelace(500_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input)
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)

  let redeemer <- list.all([Cancel, Finish, Refund])
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    None,
    redeemer,
    no_datum_o_ref,
    tx,
  )
}

test no_datum_positive_finished_campaign() {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Finished,
    }
  let campaign_datum: Data = campaign_state

  let no_datum_o_ref = OutputReference("NO_DATUM_OREF_TxHash", 0)

  let tx_ref_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input =
    txn.new_tx_input(no_datum_o_ref, campaign_address)
      |> with_asset_of_tx_input(assets.from_lovelace(500_000_000))

  let tx_output =
    txn.new_tx_output(platform_address)
      |> add_asset_to_tx_output(assets.from_lovelace(500_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input)
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)

  let redeemer <- list.all([Cancel, Finish, Refund])
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    None,
    redeemer,
    no_datum_o_ref,
    tx,
  )
}

// ## Negative Tests

test no_datum_negative_running_campaign() fail {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let campaign_datum: Data = campaign_state

  let no_datum_o_ref = OutputReference("NO_DATUM_OREF_TxHash", 0)

  let tx_ref_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input =
    txn.new_tx_input(no_datum_o_ref, campaign_address)
      |> with_asset_of_tx_input(assets.from_lovelace(500_000_000))

  let tx_output =
    txn.new_tx_output(platform_address)
      |> add_asset_to_tx_output(assets.from_lovelace(500_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input)
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)

  let redeemer <- list.any([Cancel, Finish, Refund])
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    None,
    redeemer,
    no_datum_o_ref,
    tx,
  )
}

test no_datum_negative_no_campaign_state_token_in_reference_input() fail {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Cancelled,
    }
  let campaign_datum: Data = campaign_state

  let no_datum_o_ref = OutputReference("NO_DATUM_OREF_TxHash", 0)

  let tx_ref_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)

  //   |> with_asset_of_tx_input(campaign_state_token)
  let tx_input =
    txn.new_tx_input(no_datum_o_ref, campaign_address)
      |> with_asset_of_tx_input(assets.from_lovelace(500_000_000))

  let tx_output =
    txn.new_tx_output(platform_address)
      |> add_asset_to_tx_output(assets.from_lovelace(500_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input)
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)

  let redeemer <- list.any([Cancel, Finish, Refund])
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    None,
    redeemer,
    no_datum_o_ref,
    tx,
  )
}

test no_datum_negative_does_not_refer_state_token_utxo() fail {
  //   let campaign_state =
  //     CampaignDatum {
  //       name: "Campaign Name",
  //       goal: 9_000_000_000,
  //       deadline: 1928374650000,
  //       creator: creator_address,
  //       state: Finished,
  //     }

  //   let campaign_datum: Data = campaign_state
  let no_datum_o_ref = OutputReference("NO_DATUM_OREF_TxHash", 0)

  //   let tx_ref_input =
  //     txn.new_tx_input(campaign_state_o_ref, campaign_address)
  //       |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
  //       |> with_asset_of_tx_input(campaign_state_token)
  let tx_input =
    txn.new_tx_input(no_datum_o_ref, campaign_address)
      |> with_asset_of_tx_input(assets.from_lovelace(500_000_000))

  let tx_output =
    txn.new_tx_output(platform_address)
      |> add_asset_to_tx_output(assets.from_lovelace(500_000_000))

  let tx =
    transaction.placeholder //   |> add_tx_ref_input(tx_ref_input)
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)

  let redeemer <- list.any([Cancel, Finish, Refund])
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    None,
    redeemer,
    no_datum_o_ref,
    tx,
  )
}

test no_datum_negative_not_signed_by_platform() fail {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Finished,
    }
  let campaign_datum: Data = campaign_state

  let no_datum_o_ref = OutputReference("NO_DATUM_OREF_TxHash", 0)

  let tx_ref_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input =
    txn.new_tx_input(no_datum_o_ref, campaign_address)
      |> with_asset_of_tx_input(assets.from_lovelace(500_000_000))

  let tx_output =
    txn.new_tx_output(platform_address)
      |> add_asset_to_tx_output(assets.from_lovelace(500_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input)
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)

  //   |> add_signatory(platform_pkh)
  let redeemer <- list.any([Cancel, Finish, Refund])
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    None,
    redeemer,
    no_datum_o_ref,
    tx,
  )
}
