use cardano/address.{Address, Inline, VerificationKey}
use crowdfunding/types.{PaymentKeyHash, StakeKeyHash}

pub fn address_from_tuple(key_hash_tuple: (PaymentKeyHash, StakeKeyHash)) {
  let (pkh, skh) = key_hash_tuple
  Address {
    payment_credential: pkh |> VerificationKey,
    stake_credential: if skh == "" {
      None
    } else {
      skh |> VerificationKey |> Inline |> Some
    },
  }
}
