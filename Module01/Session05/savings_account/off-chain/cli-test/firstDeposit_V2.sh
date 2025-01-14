utxoin="133f47d298caa472bdae50ee608c13d08faf83a3beb6509424cef215c4251645#1"
address=$(cat ../compiled/savings.addr) 
output="110000000"

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-inline-datum-file ../values/saver.json \
  --tx-out $address+$output \
  --tx-out-reference-script-file ../compiled/savings.uplc \
  --change-address $nami3 \
  --out-file deposit_V2.unsigned

cardano-cli conway transaction sign \
    --tx-body-file deposit_V2.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Adr03.skey \
    $PREVIEW \
    --out-file deposit_V2.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file deposit_V2.signed