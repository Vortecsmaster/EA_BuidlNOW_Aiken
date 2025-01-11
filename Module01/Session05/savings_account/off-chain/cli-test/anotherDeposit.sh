script_utxo="46c48fb708837c973eff2ee1f7115c02962fc71efd6bfb0aed46d8e56d670464#0"
script_address=$(cat ../compiled/savings_v1.addr) 
user_utxo="690813569f2cf691442fe0e9d1d5c158852f203041e4e69546c8ff2f0451a025#1"
output="710000000"
saverPKH=$(cat $HOME/Dev/Wallets/Adr08.pkh)
collateralPKH=$(cat $HOME/Dev/Wallets/Adr07.pkh)
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0"

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $script_utxo \
  --tx-in-script-file ../compiled/savings_v1.uplc \
  --tx-in-datum-file ../values/saver.json \
  --tx-in-redeemer-file ../values/value1.json \
  --tx-in $user_utxo \
  --required-signer-hash $saverPKH \
  --tx-in-collateral $collateral \
  --tx-out $script_address+$output \
  --tx-out-datum-hash-file ../values/saver.json \
  --change-address $nami3 \
  --out-file another_deposit.unsigned

cardano-cli conway transaction sign \
    --tx-body-file another_deposit.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Adr02.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr08.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr07.skey \
    $PREVIEW \
    --out-file another_deposit.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file another_deposit.signed