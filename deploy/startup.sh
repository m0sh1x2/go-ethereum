#!/bin/bash

# geth init genesis.json
geth --dev --http --http.addr 0.0.0.0 --http.api eth,web3,debug,net --http.corsdomain "https://remix.ethereum.org" --datadir=/root/.ethereum --http.vhosts="*" --allow-insecure-unlock

# in a different terminal register the contract
npx hardhat run scripts/deploy-counter.ts --build-profile production --network geth

Stop geth with CTRL +C

geth export backup01

delete all files in /root/.ethereum

geth import backup01 
run again `geth --dev --http --http.addr 0.0.0.0 --http.api eth,web3,debug,net --http.corsdomain "https://remix.ethereum.org" --datadir=/root/.ethereum --http.vhosts="*" --allow-insecure-unlock` 

fails to start for bad block:

