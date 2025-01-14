//// @hidden

use aiken/interval
use cardano/address
use cardano/assets
use cardano/transaction.{OutputReference}
use config
use crowdfunding/utils

// ## Time Constants

pub const now = 1852963074000

pub const after_now = interval.after(now)

// ## Creator Constants

pub const creator_pkh = "CREATOR_PaymentKeyHash"

pub const creator_skh = "CREATOR_StakeKeyHash"

pub const creator_address = (creator_pkh, creator_skh)

pub const creator_address_from_tuple = utils.address_from_tuple(creator_address)

// ## Campaign Constants

pub const campaign_nonce = OutputReference("CAMPAIGN_NONCE_TxHash", 0)

pub const campaign_script = "CAMPAIGN_PolicyId"

pub const campaign_address = address.from_script(campaign_script)

pub const campaign_state_token =
  assets.from_asset(campaign_script, config.state_token, 1)

pub const campaign_state_o_ref =
  OutputReference("CAMPAIGN_STATE_OREF_TxHash", 1)

// ## Platform Constants

pub const platform_pkh = "PLATFORM_PaymentKeyHash"

pub const platform_address = address.from_script("PLATFORM_ScriptHash")
