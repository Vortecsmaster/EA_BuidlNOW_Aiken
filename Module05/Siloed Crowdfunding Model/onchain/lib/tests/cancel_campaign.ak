use aiken/interval
use cardano/address
use cardano/transaction.{InlineDatum}
use crowdfunding
use crowdfunding/types.{CampaignDatum, Cancel, Cancelled, Finished, Running}
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

test cancel_campaign_positive_signed_by_creator() {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_positive_signed_by_platform() {
  let deadline = 1928374650000
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)
      |> set_validity_range(interval.after(deadline))

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

// ## Negative Tests

test cancel_campaign_negative_no_signer() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)

  //   |> add_signatory(creator_pkh)
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_platform_cancel_before_deadline() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)
      |> set_validity_range(interval.after(now))

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_platform_cancel_without_validty_range() fail {
  let deadline = 1928374650000
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(platform_pkh)

  //   |> set_validity_range(interval.after(deadline))
  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_rename_campaign() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state =
    CampaignDatum { ..initial_state, state: Cancelled, name: "Campaign Name 2" }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_change_goal() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state =
    CampaignDatum { ..initial_state, state: Cancelled, goal: 800_000_000 }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_change_deadline() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state =
    CampaignDatum { ..initial_state, state: Cancelled, deadline: now }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_change_creator() fail {
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
      state: Cancelled,
      creator: (#"badb0b", #""),
    }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_resend_campaign_state_token_to_different_stake_account_address() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(
      campaign_address |> address.with_delegation_key(#"badb0b"),
    )
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_does_not_resend_campaign_datum() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  //   let target_state = CampaignDatum { ..initial_state, state: Cancelled }
  let initial_datum: Data = initial_state

  //   let target_datum: Data = target_state
  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address) //   |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_does_not_resend_campaign_state_token() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}

test cancel_campaign_negative_change_state_from_finished_to_cancelled_instead_of_running() fail {
  let initial_state =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Finished,
    }
  let target_state = CampaignDatum { ..initial_state, state: Cancelled }

  let initial_datum: Data = initial_state
  let target_datum: Data = target_state

  let tx_input =
    txn.new_tx_input(campaign_state_o_ref, campaign_address)
      |> set_datum_of_tx_input(initial_datum |> InlineDatum)
      |> with_asset_of_tx_input(campaign_state_token)

  let tx_output =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(target_datum |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(creator_pkh)

  crowdfunding.validate_spend_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    Some(initial_datum),
    Cancel,
    campaign_state_o_ref,
    tx,
  )
}
