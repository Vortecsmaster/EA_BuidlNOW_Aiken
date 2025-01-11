utxoin="ed24c9287d374bd0c88f0a8f3c5388b67734f2d54075756ab38344dc7caad15f#6"
address=$(cat ./compiled/simple.addr)
output="110000000"

cardano-cli conway transaction build \
  --testnet-magic 2 \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-inline-datum-file ./values/datum.json \
  --change-address $nami3 \
  --out-file simple.unsigned

cardano-cli conway transaction sign \
    --tx-body-file simple.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Bob.skey \
    $PREVIEW \
    --out-file simple.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file simple.signed