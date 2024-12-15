use cardano/assets
use cardano/transaction.{InlineDatum, OutputReference}
use crowdfunding
use crowdfunding/types.{CampaignDatum, Cancelled, Finished, Refund, Running}
use crowdfunding/utils
use tests/constants.{
  campaign_address, campaign_nonce, campaign_state_o_ref, campaign_state_token,
  creator_address, creator_pkh, platform_pkh,
}
use tx_util/builder/txn.{
  add_asset_to_tx_output, add_tx_input, add_tx_output, add_tx_ref_input,
  set_datum_of_tx_input, with_asset_of_tx_input,
}

// ## Positive Tests

test refund_campaign_positive_cancelled_campaign() {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Cancelled,
    }
  let campaign_datum: Data = campaign_state

  let backer_address_1 = (#"b1", #"")
  let backer_datum_1: Data = backer_address_1

  let backer_address_2 = (#"b2", #"b2")
  let backer_datum_2: Data = backer_address_2

  let backer_address_3 = (#"b3", #"")
  let backer_datum_3: Data = backer_address_3

  let backer_address_4 = (#"b4", #"b4")
  let backer_datum_4: Data = backer_address_4

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)
  let backer_support_o_ref_3 = OutputReference("C_SUPPORT_OREF_TxHash", 3)
  let backer_support_o_ref_4 = OutputReference("D_SUPPORT_OREF_TxHash", 4)

  let backer_address_from_tuple_1 = utils.address_from_tuple(backer_address_1)
  let backer_address_from_tuple_2 = utils.address_from_tuple(backer_address_2)
  let backer_address_from_tuple_3 = utils.address_from_tuple(backer_address_3)
  let backer_address_from_tuple_4 = utils.address_from_tuple(backer_address_4)

  let tx_ref_input_campaign =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(1_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000_000))
  let tx_input_support_3 =
    txn.new_tx_input(backer_support_o_ref_3, campaign_address)
      |> set_datum_of_tx_input(backer_datum_3 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_4 =
    txn.new_tx_input(backer_support_o_ref_4, campaign_address)
      |> set_datum_of_tx_input(backer_datum_4 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(4_000_000_000))

  let tx_output_backer_1 =
    txn.new_tx_output(backer_address_from_tuple_1)
      |> add_asset_to_tx_output(assets.from_lovelace(1_000_000_000))
  let tx_output_backer_2 =
    txn.new_tx_output(backer_address_from_tuple_2)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000_000))
  let tx_output_backer_3 =
    txn.new_tx_output(backer_address_from_tuple_3)
      |> add_asset_to_tx_output(assets.from_lovelace(3_000_000_000))
  let tx_output_backer_4 =
    txn.new_tx_output(backer_address_from_tuple_4)
      |> add_asset_to_tx_output(assets.from_lovelace(4_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input_campaign)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_input(tx_input_support_3)
      |> add_tx_input(tx_input_support_4)
      |> add_tx_output(tx_output_backer_1)
      |> add_tx_output(tx_output_backer_2)
      |> add_tx_output(tx_output_backer_3)
      |> add_tx_output(tx_output_backer_4)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Refund,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Refund,
      backer_support_o_ref_2,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_3),
      Refund,
      backer_support_o_ref_3,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_4),
      Refund,
      backer_support_o_ref_4,
      tx,
    ),
  }
}

test refund_campaign_positive_finished_campaign() {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Finished,
    }
  let campaign_datum: Data = campaign_state

  let backer_address_1 = (#"b1", #"")
  let backer_datum_1: Data = backer_address_1

  let backer_address_2 = (#"b2", #"b2")
  let backer_datum_2: Data = backer_address_2

  let backer_address_3 = (#"b3", #"")
  let backer_datum_3: Data = backer_address_3

  let backer_address_4 = (#"b4", #"b4")
  let backer_datum_4: Data = backer_address_4

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)
  let backer_support_o_ref_3 = OutputReference("C_SUPPORT_OREF_TxHash", 3)
  let backer_support_o_ref_4 = OutputReference("D_SUPPORT_OREF_TxHash", 4)

  let backer_address_from_tuple_1 = utils.address_from_tuple(backer_address_1)
  let backer_address_from_tuple_2 = utils.address_from_tuple(backer_address_2)
  let backer_address_from_tuple_3 = utils.address_from_tuple(backer_address_3)
  let backer_address_from_tuple_4 = utils.address_from_tuple(backer_address_4)

  let tx_ref_input_campaign =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(1_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000_000))
  let tx_input_support_3 =
    txn.new_tx_input(backer_support_o_ref_3, campaign_address)
      |> set_datum_of_tx_input(backer_datum_3 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_4 =
    txn.new_tx_input(backer_support_o_ref_4, campaign_address)
      |> set_datum_of_tx_input(backer_datum_4 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(4_000_000_000))

  let tx_output_backer_1 =
    txn.new_tx_output(backer_address_from_tuple_1)
      |> add_asset_to_tx_output(assets.from_lovelace(1_000_000_000))
  let tx_output_backer_2 =
    txn.new_tx_output(backer_address_from_tuple_2)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000_000))
  let tx_output_backer_3 =
    txn.new_tx_output(backer_address_from_tuple_3)
      |> add_asset_to_tx_output(assets.from_lovelace(3_000_000_000))
  let tx_output_backer_4 =
    txn.new_tx_output(backer_address_from_tuple_4)
      |> add_asset_to_tx_output(assets.from_lovelace(4_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input_campaign)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_input(tx_input_support_3)
      |> add_tx_input(tx_input_support_4)
      |> add_tx_output(tx_output_backer_1)
      |> add_tx_output(tx_output_backer_2)
      |> add_tx_output(tx_output_backer_3)
      |> add_tx_output(tx_output_backer_4)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Refund,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Refund,
      backer_support_o_ref_2,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_3),
      Refund,
      backer_support_o_ref_3,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_4),
      Refund,
      backer_support_o_ref_4,
      tx,
    ),
  }
}

// ## Negative Tests

test refund_campaign_negative_running_campaign() fail {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let campaign_datum: Data = campaign_state

  let backer_address_1 = (#"b1", #"")
  let backer_datum_1: Data = backer_address_1

  let backer_address_2 = (#"b2", #"b2")
  let backer_datum_2: Data = backer_address_2

  let backer_address_3 = (#"b3", #"")
  let backer_datum_3: Data = backer_address_3

  let backer_address_4 = (#"b4", #"b4")
  let backer_datum_4: Data = backer_address_4

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)
  let backer_support_o_ref_3 = OutputReference("C_SUPPORT_OREF_TxHash", 3)
  let backer_support_o_ref_4 = OutputReference("D_SUPPORT_OREF_TxHash", 4)

  let backer_address_from_tuple_1 = utils.address_from_tuple(backer_address_1)
  let backer_address_from_tuple_2 = utils.address_from_tuple(backer_address_2)
  let backer_address_from_tuple_3 = utils.address_from_tuple(backer_address_3)
  let backer_address_from_tuple_4 = utils.address_from_tuple(backer_address_4)

  let tx_ref_input_campaign =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(1_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000_000))
  let tx_input_support_3 =
    txn.new_tx_input(backer_support_o_ref_3, campaign_address)
      |> set_datum_of_tx_input(backer_datum_3 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_4 =
    txn.new_tx_input(backer_support_o_ref_4, campaign_address)
      |> set_datum_of_tx_input(backer_datum_4 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(4_000_000_000))

  let tx_output_backer_1 =
    txn.new_tx_output(backer_address_from_tuple_1)
      |> add_asset_to_tx_output(assets.from_lovelace(1_000_000_000))
  let tx_output_backer_2 =
    txn.new_tx_output(backer_address_from_tuple_2)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000_000))
  let tx_output_backer_3 =
    txn.new_tx_output(backer_address_from_tuple_3)
      |> add_asset_to_tx_output(assets.from_lovelace(3_000_000_000))
  let tx_output_backer_4 =
    txn.new_tx_output(backer_address_from_tuple_4)
      |> add_asset_to_tx_output(assets.from_lovelace(4_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input_campaign)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_input(tx_input_support_3)
      |> add_tx_input(tx_input_support_4)
      |> add_tx_output(tx_output_backer_1)
      |> add_tx_output(tx_output_backer_2)
      |> add_tx_output(tx_output_backer_3)
      |> add_tx_output(tx_output_backer_4)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Refund,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Refund,
      backer_support_o_ref_2,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_3),
      Refund,
      backer_support_o_ref_3,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_4),
      Refund,
      backer_support_o_ref_4,
      tx,
    ),
  }
}

test refund_campaign_negative_steal_other_backers_support() fail {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Cancelled,
    }
  let campaign_datum: Data = campaign_state

  let backer_address_1 = (#"b1", #"")
  let backer_datum_1: Data = backer_address_1

  let backer_address_2 = (#"b2", #"b2")
  let backer_datum_2: Data = backer_address_2

  let hacker_address = (#"badb0b", #"")
  let hacker_datum: Data = hacker_address

  let backer_address_3 = (#"b3", #"")
  let backer_datum_3: Data = backer_address_3

  let backer_address_4 = (#"b4", #"b4")
  let backer_datum_4: Data = backer_address_4

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)
  let hacker_support_o_ref_x = OutputReference("X_SUPPORT_OREF_TxHash", 0)
  let backer_support_o_ref_3 = OutputReference("C_SUPPORT_OREF_TxHash", 3)
  let backer_support_o_ref_4 = OutputReference("D_SUPPORT_OREF_TxHash", 4)

  let backer_address_from_tuple_1 = utils.address_from_tuple(backer_address_1)
  let backer_address_from_tuple_2 = utils.address_from_tuple(backer_address_2)
  let hacker_address_from_tuple_x = utils.address_from_tuple(hacker_address)
  let backer_address_from_tuple_3 = utils.address_from_tuple(backer_address_3)
  let backer_address_from_tuple_4 = utils.address_from_tuple(backer_address_4)

  let tx_ref_input_campaign =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(1_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000_000))
  let tx_input_support_x =
    txn.new_tx_input(hacker_support_o_ref_x, campaign_address)
      |> set_datum_of_tx_input(hacker_datum |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))
  let tx_input_support_3 =
    txn.new_tx_input(backer_support_o_ref_3, campaign_address)
      |> set_datum_of_tx_input(backer_datum_3 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_4 =
    txn.new_tx_input(backer_support_o_ref_4, campaign_address)
      |> set_datum_of_tx_input(backer_datum_4 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(4_000_000_000))

  let tx_output_backer_1 =
    txn.new_tx_output(backer_address_from_tuple_1)
      |> add_asset_to_tx_output(assets.from_lovelace(900_000_000))
  let tx_output_backer_2 =
    txn.new_tx_output(backer_address_from_tuple_2)
      |> add_asset_to_tx_output(assets.from_lovelace(1_900_000_000))
  let tx_output_hacker =
    txn.new_tx_output(hacker_address_from_tuple_x)
      |> add_asset_to_tx_output(assets.from_lovelace(402_000_000))
  let tx_output_backer_3 =
    txn.new_tx_output(backer_address_from_tuple_3)
      |> add_asset_to_tx_output(assets.from_lovelace(2_900_000_000))
  let tx_output_backer_4 =
    txn.new_tx_output(backer_address_from_tuple_4)
      |> add_asset_to_tx_output(assets.from_lovelace(3_900_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input_campaign)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_input(tx_input_support_x)
      |> add_tx_input(tx_input_support_3)
      |> add_tx_input(tx_input_support_4)
      |> add_tx_output(tx_output_backer_1)
      |> add_tx_output(tx_output_backer_2)
      |> add_tx_output(tx_output_hacker)
      |> add_tx_output(tx_output_backer_3)
      |> add_tx_output(tx_output_backer_4)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Refund,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Refund,
      backer_support_o_ref_2,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(hacker_datum),
      Refund,
      hacker_support_o_ref_x,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_3),
      Refund,
      backer_support_o_ref_3,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_4),
      Refund,
      backer_support_o_ref_4,
      tx,
    ),
  }
}

test refund_campaign_negative_no_campaign_state_token_in_reference_input() fail {
  let campaign_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Finished,
    }
  let campaign_datum: Data = campaign_state

  let backer_address_1 = (#"b1", #"")
  let backer_datum_1: Data = backer_address_1

  let backer_address_2 = (#"b2", #"b2")
  let backer_datum_2: Data = backer_address_2

  let backer_address_3 = (#"b3", #"")
  let backer_datum_3: Data = backer_address_3

  let backer_address_4 = (#"b4", #"b4")
  let backer_datum_4: Data = backer_address_4

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)
  let backer_support_o_ref_3 = OutputReference("C_SUPPORT_OREF_TxHash", 3)
  let backer_support_o_ref_4 = OutputReference("D_SUPPORT_OREF_TxHash", 4)

  let backer_address_from_tuple_1 = utils.address_from_tuple(backer_address_1)
  let backer_address_from_tuple_2 = utils.address_from_tuple(backer_address_2)
  let backer_address_from_tuple_3 = utils.address_from_tuple(backer_address_3)
  let backer_address_from_tuple_4 = utils.address_from_tuple(backer_address_4)

  let tx_ref_input_campaign =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(1_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000_000))
  let tx_input_support_3 =
    txn.new_tx_input(backer_support_o_ref_3, campaign_address)
      |> set_datum_of_tx_input(backer_datum_3 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_4 =
    txn.new_tx_input(backer_support_o_ref_4, campaign_address)
      |> set_datum_of_tx_input(backer_datum_4 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(4_000_000_000))

  let tx_output_backer_1 =
    txn.new_tx_output(backer_address_from_tuple_1)
      |> add_asset_to_tx_output(assets.from_lovelace(1_000_000_000))
  let tx_output_backer_2 =
    txn.new_tx_output(backer_address_from_tuple_2)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000_000))
  let tx_output_backer_3 =
    txn.new_tx_output(backer_address_from_tuple_3)
      |> add_asset_to_tx_output(assets.from_lovelace(3_000_000_000))
  let tx_output_backer_4 =
    txn.new_tx_output(backer_address_from_tuple_4)
      |> add_asset_to_tx_output(assets.from_lovelace(4_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_ref_input(tx_ref_input_campaign)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_input(tx_input_support_3)
      |> add_tx_input(tx_input_support_4)
      |> add_tx_output(tx_output_backer_1)
      |> add_tx_output(tx_output_backer_2)
      |> add_tx_output(tx_output_backer_3)
      |> add_tx_output(tx_output_backer_4)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Refund,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Refund,
      backer_support_o_ref_2,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_3),
      Refund,
      backer_support_o_ref_3,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_4),
      Refund,
      backer_support_o_ref_4,
      tx,
    ),
  }
}

test refund_campaign_negative_does_not_refer_state_token_utxo() fail {
  //   let campaign_state =
  //     CampaignDatum {
  //       name: "Campaign Name",
  //       goal: 9_000_000_000,
  //       deadline: 1928374650000,
  //       creator: creator_address,
  //       state: Cancelled,
  //     }

  //   let campaign_datum: Data = campaign_state
  let backer_address_1 = (#"b1", #"")
  let backer_datum_1: Data = backer_address_1

  let backer_address_2 = (#"b2", #"b2")
  let backer_datum_2: Data = backer_address_2

  let backer_address_3 = (#"b3", #"")
  let backer_datum_3: Data = backer_address_3

  let backer_address_4 = (#"b4", #"b4")
  let backer_datum_4: Data = backer_address_4

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)
  let backer_support_o_ref_3 = OutputReference("C_SUPPORT_OREF_TxHash", 3)
  let backer_support_o_ref_4 = OutputReference("D_SUPPORT_OREF_TxHash", 4)

  let backer_address_from_tuple_1 = utils.address_from_tuple(backer_address_1)
  let backer_address_from_tuple_2 = utils.address_from_tuple(backer_address_2)
  let backer_address_from_tuple_3 = utils.address_from_tuple(backer_address_3)
  let backer_address_from_tuple_4 = utils.address_from_tuple(backer_address_4)

  //   let tx_ref_input_campaign =
  //     txn.new_tx_input(campaign_state_o_ref, campaign_address)
  //       |> set_datum_of_tx_input(campaign_datum |> InlineDatum)
  //       |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(1_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000_000))
  let tx_input_support_3 =
    txn.new_tx_input(backer_support_o_ref_3, campaign_address)
      |> set_datum_of_tx_input(backer_datum_3 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_4 =
    txn.new_tx_input(backer_support_o_ref_4, campaign_address)
      |> set_datum_of_tx_input(backer_datum_4 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(4_000_000_000))

  let tx_output_backer_1 =
    txn.new_tx_output(backer_address_from_tuple_1)
      |> add_asset_to_tx_output(assets.from_lovelace(1_000_000_000))
  let tx_output_backer_2 =
    txn.new_tx_output(backer_address_from_tuple_2)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000_000))
  let tx_output_backer_3 =
    txn.new_tx_output(backer_address_from_tuple_3)
      |> add_asset_to_tx_output(assets.from_lovelace(3_000_000_000))
  let tx_output_backer_4 =
    txn.new_tx_output(backer_address_from_tuple_4)
      |> add_asset_to_tx_output(assets.from_lovelace(4_000_000_000))

  let tx =
    transaction.placeholder //   |> add_tx_ref_input(tx_ref_input_campaign)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_input(tx_input_support_3)
      |> add_tx_input(tx_input_support_4)
      |> add_tx_output(tx_output_backer_1)
      |> add_tx_output(tx_output_backer_2)
      |> add_tx_output(tx_output_backer_3)
      |> add_tx_output(tx_output_backer_4)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Refund,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Refund,
      backer_support_o_ref_2,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_3),
      Refund,
      backer_support_o_ref_3,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_4),
      Refund,
      backer_support_o_ref_4,
      tx,
    ),
  }
}
