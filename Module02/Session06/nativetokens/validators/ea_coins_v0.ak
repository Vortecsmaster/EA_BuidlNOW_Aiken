use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{Finite}
use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction, ValidityRange}

/// {"constreaNFTctor":0,fields[{"constructor":0,fields:[]},{"int": 1713194931000},{"bytes": "d40e3e791bead1fd8c003f1227906b66a2a1c04e59d663798017db71"},{"int": 50}]}
pub type ConditionsRedeemer {
  action: Action,
  deadline: Int,
  owner: VerificationKeyHash,
  price: Int,
}

pub type Action {
  /// {"constructor":0,fields:[]}
  Owner
  /// "constructor":1,fields:[]} 
  Time
}

validator ea_coins {
  mint(redeemer: ConditionsRedeemer, _policy_id: PolicyId, transaction: Transaction) {
    when redeemer.action is {
      Time -> must_happen_before(transaction.validity_range, redeemer.deadline)?
      Owner -> must_be_signed_by(transaction, redeemer.owner)?
      
    }
  }
  else(_) {
    fail
  }
}

fn must_be_signed_by(transaction: Transaction, vk: VerificationKeyHash) {
  transaction.extra_signatories |> list.has(vk)
}

fn must_happen_before(range: ValidityRange, lock_expiration_time: Int) {
  when range.upper_bound.bound_type is {
    Finite(tx_latest_time) -> (lock_expiration_time >= tx_latest_time)?
    _ -> False
  }
}