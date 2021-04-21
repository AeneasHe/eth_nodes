geth --datadir data \
    --networkid 66 \
    --port "30304" \
    --verbosity 3      \
    --http  \
    --http.port "8545"   \
    --http.corsdomain="*"  \
    --ws   \
    --ws.port "8546" \
    --bootnodes "enode://11dd3d51f6628582aa6ad24f72341e6e0c9cd7f092a6e3b8193ed8b0937ccc9a6955ec93a592381482a21981c1f67d4109d6843565f0456d3978de1a42af1aa3@47.243.92.131:30303"   \
    --snapshot=false  \
    console