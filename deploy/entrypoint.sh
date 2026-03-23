#!/bin/sh
# This is the contract registraction script

# It must:
# 1. Start geth
# 2. register the smart contract
# 3. Stop geth
# 4. Make a backup of the devnet state - ready for import.

geth \
  --dev \
  --http \
  --http.addr 0.0.0.0 \
  --http.api eth,web3,debug,net \
  --http.corsdomain "https://remix.ethereum.org" \
  --datadir=/root/.ethereum \
  --http.vhosts="*" \
  --allow-insecure-unlock > geth.log 2>&1 &

# Set the process id
GETH_PID=$!
echo "PID: $GETH_PID"

# pwd
# ls -lat

# TODO: implement start/init check for geth 
echo "sleeping..."
sleep 2

echo "Registering Hardhat contract to geth"

cd hardhat
npm ci
npx hardhat run scripts/deploy-counter.ts --build-profile production --network geth

echo "Stopping geth PID: $GETH_PID"

# Gracefull shutdown of geth pid
kill -INT $GETH_PID

# wait to save and finish
echo "Waiting for geth to save and shutdown"
wait $GETH_PID

ls -lat /root/.ethereum
cd /root/.ethereum

echo "Starting checkpoint..."
tar cfz checkpoint.tar.gz .
cp checkpoint.tar.gz /root/checkpoint/
echo "Completed checkpoint"

exit 1