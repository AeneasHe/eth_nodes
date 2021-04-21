geth --datadir data --networkid 4 --port "30305" --verbosity 2      \
    --http  --http.corsdomain="*"  \
    --ws   \
    --bootnodes  "enode://28e98de783e26b970350935426fb6ee0ccead471a1f81737d55f521583e937485a46e3025774cfa68f2bab96ac0f6dcecde04b7a261afc793bdc4c303758ff91@115.230.117.172:30303"    \
    --snapshot=false  \
    console  