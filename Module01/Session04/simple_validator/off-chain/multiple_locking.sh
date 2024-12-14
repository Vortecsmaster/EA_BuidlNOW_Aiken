utxoin="ae6ff8c80055cff2baa4ca410223d77249ff2e1603d1ddccc542fa64da464b08#0"
address=$(cat ./compiled/simple.addr)
output="110000000"

cardano-cli conway transaction build \
  --testnet-magic 2 \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-inline-datum-file ./values/datum.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file ./values/adam_datum.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file ./values/duncan_datum.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file ./values/max_datum.json \
  --change-address $nami3 \
  --out-file simple.unsigned

# cardano-cli conway transaction sign \
#     --tx-body-file simple.unsigned \
#     --signing-key-file $HOME/Dev/Wallets/Adr08.skey \
#     $PREVIEW \
#     --out-file simple.signed

# cardano-cli conway transaction submit \
#     $PREVIEW \
#     --tx-file simple.signed