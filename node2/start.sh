nohup geth --datadir data --networkid 4  \
    --port "30308" --verbosity 3    \
    --http   --http.port "8547"  --http.corsdomain="*"  \
    --ws    --ws.port "8548" \
    --bootnodes  "enode://28e98de783e26b970350935426fb6ee0ccead471a1f81737d55f521583e937485a46e3025774cfa68f2bab96ac0f6dcecde04b7a261afc793bdc4c303758ff91@125.119.146.0:30303" \
    console   \
    >>geth.log & 