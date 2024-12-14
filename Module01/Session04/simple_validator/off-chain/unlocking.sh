utxoin="49913745c00113942b8be1477ec393824342ecc80539cd9c93862e81588faa46#0"
address=$nami3
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0" 
output="100000000"
signer1=$(cat $HOME/Dev/Wallets/Adr08.pkh)
signer2=$(cat $HOME/Dev/Wallets/Bob.pkh)

cardano-cli conway transaction build \
  --testnet-magic 2 \
  --tx-in $utxoin \
  --tx-in-script-file ./compiled/simple.uplc \
  --tx-in-datum-file ./values/datum.json \
  --tx-in-redeemer-file ./values/value_0.json \
  --required-signer-hash $signer1 \
  --required-signer-hash $signer2 \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $nami3 \
  --out-file simple_unlocking.unsigned

cardano-cli conway transaction sign \
    --tx-body-file simple_unlocking.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Bob.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr07.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr08.skey \
    $PREVIEW \
    --out-file simple_unlocking.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file simple_unlocking.signed