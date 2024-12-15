use aiken/interval
use cardano/address
use cardano/assets
use cardano/transaction.{InlineDatum, OutputReference}
use crowdfunding
use crowdfunding/types.{CampaignDatum, Finish, Finished, Running}
use tests/constants.{
  campaign_address, campaign_nonce, campaign_state_o_ref, campaign_state_token,
  creator_address, creator_address_from_tuple, creator_pkh, now, platform_pkh,
}
use tx_util/builder/txn.{
  add_asset_to_tx_output, add_signatory, add_tx_input, add_tx_output,
  set_datum_of_tx_input, set_datum_of_tx_output, set_validity_range,
  with_asset_of_tx_input,
}

// ## Positive Tests

test finish_campaign_positive_signed_by_creator() {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)
      |> add_signatory(creator_pkh)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_positive_signed_by_platform() {
  let deadline = 1928374650000
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)
      |> add_signatory(platform_pkh)
      |> set_validity_range(interval.after(deadline))

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

// ## Negative Tests

test finish_campaign_negative_no_signer() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  //   |> add_signatory(creator_pkh)
  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_platform_cancel_before_deadline() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)
      |> add_signatory(platform_pkh)
      |> set_validity_range(interval.after(now))

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_positive_platform_cancel_without_validty_range() fail {
  let deadline = 1928374650000
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)
      |> add_signatory(platform_pkh)

  //   |> set_validity_range(interval.after(deadline))
  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_rename_campaign() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state =
    CampaignDatum { ..initial_state, state: Finished, name: "Campaign Name 2" }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_change_goal() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state =
    CampaignDatum { ..initial_state, state: Finished, goal: 800_000_000 }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_change_deadline() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state =
    CampaignDatum { ..initial_state, state: Finished, deadline: now }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_change_creator() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state =
    CampaignDatum {
      ..initial_state,
      state: Finished,
      creator: (#"badb0b", #""),
    }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_resend_campaign_state_token_to_different_stake_account_address() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(
      campaign_address |> address.with_delegation_key(#"badb0b"),
    )
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_does_not_resend_campaign_datum() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  //   let target_state = CampaignDatum { ..initial_state, state: Finished }
  let initial_datum: Data = initial_state

  //   let target_datum: Data = target_state
  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address) //   |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_does_not_resend_campaign_state_token() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_does_not_reach_goal() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(5_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(7_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_does_not_send_supports_to_creator() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Finished }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  let hacker_address =
    address.from_verification_key(#"badb0b")
      |> address.with_delegation_key(#"badb0b")

  let tx_input_goal =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  let tx_output_campaign =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_hacker =
    txn.new_tx_output(hacker_address)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2)
      |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_hacker)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(initial_datum),
      Finish,
      campaign_state_o_ref,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}

test finish_campaign_negative_does_not_consume_state_token_utxo() fail {
  //   let initial_state =
  //     CampaignDatum {
  //       name: "Campaign Name",
  //       goal: 9_000_000_000,
  //       deadline: 1928374650000,
  //       creator: creator_address,
  //       state: Running,
  //     }
  //   let target_state = CampaignDatum { ..initial_state, state: Finished }
  //   let initial_datum: Data = initial_state
  //   let target_datum: Data = target_state
  let backer_datum_1: Data = (#"b1", #"")
  let backer_datum_2: Data = (#"b2", #"b2")

  let backer_support_o_ref_1 = OutputReference("A_SUPPORT_OREF_TxHash", 1)
  let backer_support_o_ref_2 = OutputReference("B_SUPPORT_OREF_TxHash", 2)

  //   let tx_input_goal =
  //     txn.new_tx_input(campaign_state_o_ref, campaign_address)
  //       |> set_datum_of_tx_input(initial_datum |> InlineDatum)
  //       |> with_asset_of_tx_input(campaign_state_token)
  let tx_input_support_1 =
    txn.new_tx_input(backer_support_o_ref_1, campaign_address)
      |> set_datum_of_tx_input(backer_datum_1 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(3_000_000_000))
  let tx_input_support_2 =
    txn.new_tx_input(backer_support_o_ref_2, campaign_address)
      |> set_datum_of_tx_input(backer_datum_2 |> InlineDatum)
      |> with_asset_of_tx_input(assets.from_lovelace(6_000_000_000))

  //   let tx_output_campaign =
  //     txn.new_tx_output(campaign_address)
  //       |> set_datum_of_tx_output(target_datum |> InlineDatum)
  //       |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_creator =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(9_000_000_000))

  let tx =
    transaction.placeholder //   |> add_tx_input(tx_input_goal)
      |> add_tx_input(tx_input_support_1)
      |> add_tx_input(tx_input_support_2) //   |> add_tx_output(tx_output_campaign)
      |> add_tx_output(tx_output_creator)

  and {
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_1),
      Finish,
      backer_support_o_ref_1,
      tx,
    ),
    crowdfunding.validate_spend_campaign(
      platform_pkh,
      creator_pkh,
      campaign_nonce,
      Some(backer_datum_2),
      Finish,
      backer_support_o_ref_2,
      tx,
    ),
  }
}
