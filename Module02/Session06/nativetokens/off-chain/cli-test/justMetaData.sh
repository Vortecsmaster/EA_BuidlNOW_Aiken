utxoin1="e623894e267cf3d4553327108d566d61b01298a1b56363b260ffb5e768578913#0"
output="1500000"

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-out $nami3+$output \
  --change-address $nami3 \
  --metadata-json-file ../values/metadata.json \
  --out-file justMetaData.unsigned

cardano-cli conway transaction sign \
    --tx-body-file justMetaData.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Bob.skey \
    $PREVIEW \
    --out-file justMetaData.signed

 cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file justMetaData.signed