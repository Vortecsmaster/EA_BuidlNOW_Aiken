script_utxo="8cb72b591539c812458d8e4463866812148093516d4bb16e4debcec42a5e3ada#0"
output="700000000"
saverPKH=$(cat $HOME/Dev/Wallets/Adr08.pkh)
collateralPKH=$(cat $HOME/Dev/Wallets/Adr07.pkh)
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0"
Adr08=$(cat $HOME/Dev/Wallets/Adr08.addr)

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $script_utxo \
  --tx-in-script-file ../compiled/savings_v1.uplc \
  --tx-in-datum-file ../values/saver.json \
  --tx-in-redeemer-file ../values/value0.json \
  --required-signer-hash $saverPKH \
  --tx-in-collateral $collateral \
  --tx-out $Adr08+$output \
  --change-address $nami3 \
  --out-file withdraw.unsigned

cardano-cli conway transaction sign \
    --tx-body-file withdraw.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Adr08.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr07.skey \
    $PREVIEW \
    --out-file withdraw.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file withdraw.signed
