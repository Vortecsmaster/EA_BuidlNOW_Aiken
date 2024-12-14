use aiken/crypto.{VerificationKeyHash}
use cardano/transaction.{OutputReference, Transaction}
use aiken/collection/list

pub type SimpleDatum {
    signer1: VerificationKeyHash, 
    signer2: VerificationKeyHash
}


validator simple {
    spend(datum: Option<SimpleDatum>, _redeemer: Int, _utxo: OutputReference, tx_info: Transaction) {
        expect Some(datum) = datum
        signed_by_signers(datum.signer1, datum.signer2, tx_info.extra_signatories)
    }
}

fn signed_by_signers(signer1: VerificationKeyHash, signer2: VerificationKeyHash, signatories: List<VerificationKeyHash>) -> Bool {
      is_signed_by(signer1, signatories) && is_signed_by(signer2, signatories)
}

fn is_signed_by(
  signer: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool {    
  list.has(signatories, signer)
}