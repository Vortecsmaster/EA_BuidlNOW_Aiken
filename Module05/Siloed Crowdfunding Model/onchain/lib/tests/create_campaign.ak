use cardano/address
use cardano/assets
use cardano/transaction.{InlineDatum, OutputReference}
use crowdfunding
use crowdfunding/types.{CampaignDatum, Finished, Running}
use tests/constants.{
  after_now, campaign_address, campaign_nonce, campaign_script,
  campaign_state_token, creator_address, creator_address_from_tuple, creator_pkh,
  platform_pkh,
}
use tx_util/builder/txn.{
  add_asset_to_tx_output, add_mint, add_tx_input, add_tx_output,
  set_datum_of_tx_output, set_validity_range, with_asset_of_tx_input,
}

// ## Positive Test

test create_campaign_positive_test() {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

// ## Negative Tests

test create_campaign_negative_0_goal() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 0,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_past_deadline() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_create_campaign_for_someone_else() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: (#"badb0b", #""),
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_invalid_initial_state() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Finished,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_consume_a_different_nonce_o_ref() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(OutputReference(#"badb0b", 0), creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_consume_a_different_nonce_address() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, #"badb0b" |> address.from_verification_key)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_send_campaign_state_token_to_different_stake_account_address() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(
      campaign_address |> address.with_delegation_key(#"badb0b"),
    )
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_does_not_set_campaign_datum() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address) //   |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_does_not_send_campaign_state_token() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(campaign_state_token)

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_does_not_mint_state_token() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input) //   |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)
      |> set_validity_range(after_now)

  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}

test create_campaign_negative_does_not_set_transaction_validity_range() fail {
  let redeemer =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: creator_address,
      state: Running,
    }

  let tx_input =
    txn.new_tx_input(campaign_nonce, creator_address_from_tuple)
      |> with_asset_of_tx_input(assets.from_lovelace(2_000_000))

  let tx_output_1 =
    txn.new_tx_output(campaign_address)
      |> set_datum_of_tx_output(redeemer |> InlineDatum)
      |> add_asset_to_tx_output(campaign_state_token)
  let tx_output_2 =
    txn.new_tx_output(creator_address_from_tuple)
      |> add_asset_to_tx_output(assets.from_lovelace(2_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_mint(campaign_state_token)
      |> add_tx_output(tx_output_1)
      |> add_tx_output(tx_output_2)

  //   |> set_validity_range(after_now)
  crowdfunding.validate_mint_campaign(
    platform_pkh,
    creator_pkh,
    campaign_nonce,
    redeemer,
    campaign_script,
    tx,
  )
}
