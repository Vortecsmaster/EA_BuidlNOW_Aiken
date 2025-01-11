
use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{Finite}
use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction, ValidityRange}


/// {"constructor":0,fields[{"int":0},{"int": 1713194931000},{"bytes": "d40e3e791bead1fd8c003f1227906b66a2a1c04e59d663798017db71"},{"int": 50}]}
pub type ConditionsRedeemer {
  action: Action,
  deadline: Int,
  owner: VerificationKeyHash,
  price: Int,
}

/// - 0 -> Owner
/// - 1 -> Time
pub type Action = 
  Int

validator ea_nft_v0
() {
  mint(
    redeemer: ConditionsRedeemer,
    _policy_id: PolicyId,
    transaction: Transaction,
  ) {
    when redeemer.action is {
        0 -> must_be_signed_by(transaction, redeemer.owner)?
        1 -> must_happen_before(transaction.validity_range, redeemer.deadline)?
        _ -> False
      }
  }

  else(_) {
    fail
  }
}

pub fn must_be_signed_by(transaction: Transaction, vk: VerificationKeyHash) {
  list.has(transaction.extra_signatories,vk)
}

pub fn must_happen_before(range: ValidityRange, lock_expiration_time: Int) {
  when range.upper_bound.bound_type is {
    Finite(tx_latest_time) -> (lock_expiration_time >= tx_latest_time)?
    _ -> False
  }
}


