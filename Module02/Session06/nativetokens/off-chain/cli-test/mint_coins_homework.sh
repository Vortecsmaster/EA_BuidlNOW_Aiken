utxoin1="500889d2ecf989dd0fdf0c6477e9a4d6f79d9c19f28a9f74c3fe7beae33e32b6#0"
policyid=$(cat ../compiled/ea_coins_homework.pid)
output="1100000000"
tokenMintedAmount="440"
tokenAmount="220"
tokenname="$(echo -n "Homeworkcoin-λ-🐦😍" | xxd -ps | tr -d '\n')"
mintingScript="../compiled/ea_coins_homework.uplc"
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0"
ownerPKH=$(cat $HOME/Dev/Wallets/Bob.pkh)
notneeded="--invalid-hereafter 69918972"

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $utxoin1 \
  --required-signer-hash $ownerPKH \
  --tx-in-collateral $collateral \
  --tx-out $nami3+$output+"$tokenMintedAmount $policyid.$tokenname" \
  --change-address $Bob \
  --mint "$tokenMintedAmount $policyid.$tokenname" \
  --mint-script-file $mintingScript \
  --mint-redeemer-file ../values/redeemer.json \
  --invalid-hereafter 69919767 \
  --out-file mintTx.unsigned

cardano-cli conway transaction sign \
    --tx-body-file mintTx.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Bob.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr07.skey \
    $PREVIEW \
    --out-file mintTx.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file mintTx.signed