#!/bin/bash

echo "Starting test"

# Start the devnet
docker compose up -d

# Register the smart contract and get the address - we can add failiure logs/verification here
cd hardhat
# ADDRESS=$(npx hardhat run scripts/deploy-counter.ts --build-profile production --network geth | grep address | awk '{ print $2}')
ADDRESS=$(npx hardhat run scripts/deploy-counter.ts --build-profile production --network geth | grep address | awk '{ print $3}')

echo $ADDRESS

echo "Verify that the smart contract is deployed:"

# ADDRESS="0x3a220f351252089d385b29beca14e27f204c296a"

curl http://localhost:8545 \
  -X POST \
  -H "Content-Type: application/json" \
  --data @- <<EOF
{
  "jsonrpc":"2.0",
  "method":"eth_getCode",
  "params":["$ADDRESS","latest"],
  "id":1
}
EOF

cd ..
pwd

# Shut down the devnet
docker compose down -v