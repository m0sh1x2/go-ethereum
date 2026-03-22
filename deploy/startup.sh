#!/bin/bash

# geth init genesis.json
geth --dev --http --http.addr 0.0.0.0 --http.api eth,web3,debug,net --http.corsdomain "https://remix.ethereum.org" --datadir=/root/.ethereum --http.vhosts="*" --allow-insecure-unlock