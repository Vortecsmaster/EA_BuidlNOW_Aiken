utxoin="9420ab95a7e75595c8004a1ae46f30b631047ae4a19bba065b180ccf7cf0dd04#0"
address=$nami3
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0" 
output="100000000"
signer1=$(cat $HOME/Dev/Wallets/Adr08.pkh)
signer2=$(cat $HOME/Dev/Wallets/Bob.pkh)

cardano-cli conway transaction build \
  --testnet-magic 2 \
  --tx-in $utxoin \
  --tx-in-script-file ./compiled/simple.uplc \
  --tx-in-inline-datum-present \
  --tx-in-redeemer-file ./values/value_0.json \
  --required-signer-hash $signer1 \
  --required-signer-hash $signer2 \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --tx-out $address+$value_input_minus_allotheroutputs_minus_fee \
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