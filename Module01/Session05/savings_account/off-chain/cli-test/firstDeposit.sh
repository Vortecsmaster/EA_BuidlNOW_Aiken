utxoin="7ed6b69cd7feb5608372f9d950c3be6b89a6a1ca1f30b856679a4fcdcfd0f924#1"
address=$(cat ../compiled/savings.addr) 
output="110000000"

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file ../values/saver.json \
  --change-address $nami3 \
  --out-file deposit.unsigned

cardano-cli conway transaction sign \
    --tx-body-file deposit.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Adr03.skey \
    $PREVIEW \
    --out-file deposit.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file deposit.signed