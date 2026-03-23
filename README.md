# LimeChain 🍋 - DevOps Take Home Task Solution Documentation

Expected initial rough time to finish the task - 1 week.

Sub tasks should take several hours each - but I lack some terminology and must find good/best practices for deployment and understand how the blockchain and the go-ethereum project works.

Original README.md file is [README_MAIN.md](./README_MAIN.md)

## Requirements based on research

Running local devnet:
- geth is an execution clinet and requires a consensus client to work - https://geth.ethereum.org/docs/getting-started/consensus-clients
    - geth might also require a genesis file/block to run?
    - does dev mode support all features of the mainnet?
    - additional information about Developer mode - https://geth.ethereum.org/docs/developers/dapp-developer/dev-mode
        - requires knowledge of Solidity and Smart Contract Deployment - https://docs.soliditylang.org/en/v0.8.35-pre.1/, https://ethereum.org/developers/tutorials/deploying-your-first-smart-contract/
        - geth also supports custom genesis configuration based on docs/guide `geth --dev dumpgenesis`
        - setting up a a whole devnet will require a lot of research and testing I will Keep it as simple as possible. TODO: Get back to this if I have /timeleft.

- consensus clients might require a validator client - https://ethereum.org/glossary/#consensus-client
    - consensus clients can also require a beacon chain?
    - Prism written in GO supports validator and beacon-chain - seems like it fits the requirements for the task, but how does it work? - https://prysm.offchainlabs.com/docs/install-prysm/install-with-docker/ 
- validator clients might require 32 eth to run



### Possible/Similar implementations:
- https://github.com/OffchainLabs/eth-pos-devnet/tree/master


## Phase 1 CI/CD GitHub Actions and Container Building
- Fork the go-ethereumn repo

- Set up GitHub actions with PR with label CI:Build
  - build new docker image of the given project - so we need a Dockerfile with multi-stage build
  - upload to a container registry
  - libc might not be required in the build for CGO_ENABLED - but we we must check and note this that we can do it.

- set up docker-compose that runs local devnet with the new image 

Readings:
- Artifact attestations - https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations

## Phase 2 

- Research hardhat
- Create Sample HardHat Project - following docs - I guess I dont have to learn the whole framework
- 



# Go Ethereum

Tasks:
- Build the image
- Set up docker compose for the local devnet

One of the tools that we can use based on docs is Kurtosis  that has this package: - https://github.com/ethpandaops/ethereum-package but the task requires us to run it in a docker-compose.yaml file.

The requirements to run a devnet based on research: 




TODO readings:
- https://geth.ethereum.org/docs/getting-started
- https://geth.ethereum.org/docs/fundamentals/node-architecture
- https://geth.ethereum.org/docs/fundamentals

MONITORING - https://geth.ethereum.org/docs/monitoring/dashboards


- Choose a stable release branch - v1.17.1

run a test build with the default provided image:

```bash
docker build -t go-etherium:1.17.1 -f Dockerfile .
```

Security:
- https://geth.ethereum.org/docs/fundamentals/security

```bash
# Block:
- 8545 # for the JSON-RPC requests
# Allow:
- TCP 30303
- UDP 30303
```
Exposing api endpoints require:
- proxies,
- WAFs/Firewall
- App-level filtering
- rate limits
- logging
- tls termination
- monitoring

All ports:
- 8545 TCP, used by the HTTP based JSON RPC API
- 8546 TCP, used by the WebSocket based JSON RPC API
- 8547 TCP, used by the GraphQL API
- 30303 TCP and UDP, used by the P2P protocol running the network


# Task 3 Hardhat

- Understand what Hardhat is
- Set up hardhat
- Deploy the sample hardhad project into the docker-compose devnet
- Run the whole devnet + hardhad project/contarct inside the github actions pipeline
    - is this a typo in the task, will GitHub actions allow this, and when do I terminate + how do I test in the pipeline - TODO
- build the image with the hardhat contracts in it + set up appropriate tag/version.


Plan for actions/workflows:

- run the geth devnet in the pipeline - maybe use docker-compose inside of it with shared workdir?
- register the smart-contract
- shut down geth - because export or backups do not work when it is active
- make a backup of the /root/.ethereum directory 
- initiate the new geth image build with the backup - so we have the smart contract registered in the new image.
- verify steps - check if the tags are valid

other:
- running geth as a workflow service won't work - filesystem is not shared - no backup is possible
- running inline docker commands doesn't  work as expected, doesn't run in the background - so only option for now is the `docker-compose` file with shared directory and direct registration of the contract + shutdown and then backup/export into the new image for build.

TODO: Remember to enable go build caching for the Dockerfiles - https://docs.docker.com/build/cache/optimize/

### HardHad Container Contract build steps:

Run the `docker-compose.contracts.yml` so that we can execute the `deploy/entrypoint.sh` which runs geth in dev mode in background, registers the `hardhat` contrac, gracefully shuts down geth and then exports the devnet state archive at `deploy/checkpoint.tar.gz` that will be used in `Dockerfile.contracts` for the next build step that will run in Github Actions.

- `deploy/Dockerfile.contracts` - contains the devnet + contract checkpoint - uses the alltools image as we assume that it will be used by developers.

```Dockerfile
COPY ./deploy/checkpoint/checkpoint.tar.gz .
RUN mkdir /root/.ethereum && tar xfz checkpoint.tar.gz -C /root/.ethereum
```

Verify if the contracts are applied:

```bash
cd /root/.ethereum
geth attach geth.ipc

# and run - based on Gemini this should show all addresses in the devchain + show which one has a contract address

var latest = eth.blockNumber;
console.log("Scanning " + latest + " blocks...");

for (var i = 1; i <= latest; i++) {
  var block = eth.getBlock(i, true);
  if (block != null && block.transactions != null) {
    block.transactions.forEach(function(tx) {
      var receipt = eth.getTransactionReceipt(tx.hash);
      // If a transaction receipt has a contractAddress, it was a deployment!
      if (receipt && receipt.contractAddress) {
        console.log("Block " + i + " | TX: " + tx.hash);
        console.log("--> Contract Address: " + receipt.contractAddress);
      }
    });
  }
}




 Supports Tests:

 ```bash
npx hardhat test solidity --coverage
npx hardhat test nodejs --coverage
npx hardhat test --coverage
```

```bash
# Check if the deployment module works
npx hardhat ignition deploy ignition/modules/Counter.ts

# Deploy to a local dev node
npx hardhat node

# In a different terminal test(this should be the test for the CI/CD pipeline):
npx hardhat ignition deploy ignition/modules/Counter.ts --network localhost
---

Deploying to a live network
- should work with the go-ethereum devnet?

```js
import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { defineConfig } from "hardhat/config";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  solidity: {
    version: "0.8.28",
  },
  networks: {
    sepolia: {
      type: "http",
      url: "<SEPOLIA_RPC_URL>",
      accounts: ["<SEPOLIA_PRIVATE_KEY>"],
    },
  },
});
```
Deploy the smart contract with the script:

```bash
npx hardhat run scripts/deploy-counter.ts --build-profile production --network geth
```


Veriify that the contract is valid with the new contract address: 

```bash
curl http://localhost:8545 \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_getCode",
    "params":["0xdb7d6ab1f17c6b31909ae466702703daef9269cf","latest"],
    "id":1
  }'
```

Can be verified also with:

```javascript
geth attach http://localhost:8545
// result:
> eth.getCode("0xdb7d6ab1f17c6b31909ae466702703daef9269cf")
"0x608060405234801561000f575f5ffd5b506004361061003f575f3560e01c80630c55699c14610043578063371303c01461005d57806370119d0614610067575b5f5ffd5b61004b5f5481565b60405190815260200160405180910390f35b61006561007a565b005b610065610075366004610170565b6100c6565b60015f5f82825461008b9190610187565b9091555050604051600181527f51af157c2eee40f68107a47a49c32fbbeb0a3c9e5cd37aa56e88e6be92368a819060200160405180910390a1565b5f81116101255760405162461bcd60e51b815260206004820152602360248201527f696e6342793a20696e6372656d656e742073686f756c6420626520706f73697460448201526269766560e81b606482015260840160405180910390fd5b805f5f8282546101359190610187565b90915550506040518181527f51af157c2eee40f68107a47a49c32fbbeb0a3c9e5cd37aa56e88e6be92368a819060200160405180910390a150565b5f60208284031215610180575f5ffd5b5035919050565b808201808211156101a657634e487b7160e01b5f52601160045260245ffd5b9291505056fea26469706673582212209f29cef328aaec5c90c03d4b39dd6e8a1d7ab6a444aef1af6e373493c9ca60b864736f6c634300081c0033"
```

# Task 4 - Running hardhat ingregration test agains the devnet docker image

Documentations that there is Multichain support for the hardhat viem test suit: https://hardhat.org/docs/guides/testing/using-viem#multichain-support

Guess the `--network geth` flag is enough to run the test agains the geth node:

```bash
npx hardhat test --network geth

# response
...

  Counter
    ✔ Should emit the Increment event when calling the inc() function
    ✔ The sum of the Increment events should match the current value (142ms)

7 passing (5 solidity, 2 nodejs)
```

Seems to be working, so I will add it into the pipeline for testing after deploy - for this we might need a new way to test the built image.

Possible way to set a custom env for the test: https://stackoverflow.com/questions/57968497/how-do-i-set-an-env-var-with-a-bash-expression-in-github-actions - thats new, should test or write it more if it's a good practice.

```yaml
# Source - https://stackoverflow.com/a/57969570
# Posted by peterevans, modified by community. See post 'Timeline' for change history
# Retrieved 2026-03-23, License - CC BY-SA 4.0

name: my workflow
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set env
      run: echo "GITHUB_SHA_SHORT=$(echo $GITHUB_SHA | cut -c 1-6)" >> $GITHUB_ENV
    - name: Test
      run: echo $GITHUB_SHA_SHORT
```

IMPORTANT: We are aborting on the exit container state of the test, we don't care if geth is alive or forcefully terminated:

```bash
      - name: Run Compose Test
        run: docker compose -f docker-compose.tests.yml up --abort-on-container-exit --exit-code-from test-geth
```

Also we are setting up a custom `hardhat.config.test.ts` so that we can connect via dns to `http://geth:8545`.



# Task 5 - Terraform k8s Cluster

Task requires:
- Terraform k8s cluster
- Automatic deployment of the geth devnet + smart contract container
- StatefulStet configuration, Volume, Service, Firewall Rules
- Possibly Optional: LoadBalancer, Ingress, DNS + Public domain? 

How are developers going to use the devnet? Tilt, Skaffold, Telepresence? - not sure - TODO: Think later if this is important focus on MVP solution.

I have more experinece with k8s so I will start with the k8s manifests and test locally with minikube, once all confiugrations are complete I will proceed with the Terraform setup.

Kubernetes manifests will be located at: `deploy/manifests'.
  - If timeleft set up ArgoCD for automatic deployments

Terraform configurations will be loacted at : 'deploy/terraform'.

## Terraform GCP Cluster Setup

We are going to use this guide https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke and set up a basic single node cluster with terraform so that we can deploy the geth devnet into it.

Setup is very slow, requires 20 minutes to start single node.

Setup requirements:

```bash
terraform init
terraform apply

gcloud components install gke-gcloud-auth-plugin

# Deploy the service
cd deploy/manifests
k apply -k overlays/dev
```

Aditionally the geth node requires more than 245m cpu request otherwise the health-checks will be very slow, so consuder using those values:

```yaml
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
          limits:
            cpu: 500m
            memory: 256Mi
```




# Task 6(Bonus)- Blockscout implementation in docker-compose.

Blockscout provides a default docker-compose documentation - https://docs.blockscout.com/setup/deployment/docker-compose-deployment

They have setup for `geth` - `docker compose -f geth.yml up -d` - we are going to use it in our default `docker-compose.yml` so that we can deploy it directly.

Source of compose that is used our repo: https://github.com/blockscout/blockscout/tree/master/docker-compose

Based on the repo Blockscout requires:

- postgres
- redis
- blockscout backend
- nginx proxy to bind backend, frontend and microservices
- blockscout explored

and 5 micro-services:
- stats
- sol2uml visualizer
- sig-provider
- user-ops-indexer

There is an option to run only the exporer without micro-services - `Running only explorer without microservices: docker-compose -f no-services.yml up -d` this might be what we need with `All of the configs assume the Ethereum JSON RPC is running at http://localhost:8545.`

Addiitonal geth requirements - https://docs.blockscout.com/setup/requirements/client-settings#geth:

```bash
sudo /usr/bin/geth --http --http.addr 0.0.0.0 --port 30303 --http.port 8545 --http.api debug,net,eth,shh,web3,txpool --ws.api "eth,net,web3,network,debug,txpool" --ws --ws.addr 0.0.0.0 --ws.port 8546 --ws.origins "*" --sepolia --datadir=/rinkeby --syncmode "full" --gcmode "archive" --http.vhosts "*"
```

Known Blockscout startup issues:

Invalid rate limit config:
```bash
{"time":"2026-03-23T18:18:15.217Z","severity":"error","message":"Failed to fetch rate limit config: :invalid_config_url. Fallback to local config.","metadata":{}}
warning: using map.field notation (without parentheses) to invoke function BlockScoutWeb.Endpoint.__sockets__() is deprecated, you must add parentheses instead: remote.function()
  (phoenix 1.5.14) lib/phoenix/endpoint/supervisor.ex:139: Phoenix.Endpoint.Supervisor.socket_children/1
  (phoenix 1.5.14) lib/phoenix/endpoint/supervisor.ex:105: Phoenix.Endpoint.Supervisor.init/1
  (stdlib 6.2.2) supervisor.erl:869: :supervisor.init/1
  (stdlib 6.2.2) gen_server.erl:2229: :gen_server.init_it/2
  (stdlib 6.2.2) gen_server.erl:2184: :gen_server.init_it/6
```
For dev mode we can try to disable the rate limit, so that we can see if hte backedn wil lstart:

```bash
API_RATE_LIMIT_DISABLED=true
```

Disabled API rate limit fixes the restarts of the backend. But we also have issues when starting/stopping multiple times, current fix is to remove the disk mounts and set up custom volumes in the main `docker-compose.yml`:

```yaml
# docker-compose.yml
volumes:
  geth-datadir:
  redis-data:
  blockscout-db-data:
  logs:
  dets:
```

After this we can run `compose up -d` and `down -v` without getting unexpected behavior or errors on the local devnet block explorer. 

We can also test if new accounts and transactions are logged in geth shell:

```bash
# create account
clef newaccount --keystore keystore/

# get accounts


# make transaction
eth.sendTransaction({
  from: '0x71562b71999873db5b286df957af199ec94617f7',
  to: '0x1547c6e06f89640c4db6ac3476e21f9ebb5c52da',
  value: web3.toWei(0.1, 'ether')
});
```

Check `localhost` and you will see a `Conin transfer` `+ `Susccess` transaction with values and fees.


```bash
{"time":"2026-03-23T18:03:17.628Z","severity":"info","message":"Application indexer exited: Indexer.Application.start(:normal, []) returned an error: shutdown: failed to start child: Indexer.Supervisor\n    ** (EXIT) shutdown: failed to start child: Indexer.NFTMediaHandler.Queue\n        ** (EXIT) an exception was raised:\n            ** (MatchError) no match of right hand side value: {:error, {:file_error, ~c\"./dets/queue_storage\", :eacces}}\n                (indexer 9.0.2) lib/indexer/nft_media_handler/queue.ex:67: Indexer.NFTMediaHandler.Queue.init/1\n                (stdlib 6.2.2) gen_server.erl:2229: :gen_server.init_it/2\n                (stdlib 6.2.2) gen_server.erl:2184: :gen_server.init_it/6\n                (stdlib 6.2.2) proc_lib.erl:329: :proc_lib.init_p_do_apply/3","metadata":{}}
```

- https://github.com/blockscout/blockscout/issues/1413
recommended solution: 
```yaml
export ETHEREUM_JSONRPC_HTTP_URL=http://localhost:8545
export ETHEREUM_JSONRPC_TRACE_URL=http://localhost:8545
export ETHEREUM_JSONRPC_WS_URL=ws://localhost:8546
export ETHEREUM_JSONRPC_VARIANT=parity
```
doesn't work.


# Faced Issues/Errors

When trying ot register a the demo smart contract to geth devnet:

```bash
npx hardhat ignition deploy ignition/modules/Counter.ts --network geth
✔ Confirm deploy to network geth (1337)? … yes
Hardhat Ignition 🚀

Resuming existing deployment from ./ignition/deployments/chain-1337

Deploying [ CounterModule ]


Batch #1
  Executing CounterModule#Counter...
```

we get the following error in geth devnode:

```
geth-1  | WARN [03-22|13:18:39.894] Served hardhat_getAutomine               conn=172.20.0.1:55460 reqid=4 duration="5.991µs" err="the method hardhat_getAutomine does not exist/is not available"
```

This is something related to the deployment, no solution at the moment.

Is this the right way to deploy the smart contract with hardhat and geth?
- no, hardhat has docs on how to deploy with custom scripts - https://hardhat.org/docs/guides/deployment/using-scripts

The solution is fixed with scripts/deploy-counter.ts - The viem version.

The `hardhat_getAutomine` error is related to a method supported by hardhad ignition that is not supported by geth, but it does not affect the deployment of the smart contract. The deployment is successful and the error can be ignored.

---

Invalid genesis configuration when running the node after `geth import`.

```bash
geth-1  | Fatal: Bad developer-mode genesis configuration: terminalTotalDifficulty must be 0
```
Most likely we also have to specify the genesis configuration on import for the `--dev` mode to work?


## New Terms and Tech I need to learn


### go-ethereum
The official Go implementation of the Ethereum protocol, also known as geth. It includes a command-line interface and a library for building Ethereum applications in Go.

geth - The Etherium go client implementation
clef - signing tool for geth
devp2p - utility to interact with nodes on the networking layer without running a whole blockchain
abigen - source code generator to convert Ethereium contract definitions into easy-to-use, compile type-safe Go packages. Can also accept Solidity soruce files.
evm - developer utility to interact with the Ethereum Virtual Machine (EVM) without running a whole blockchain
rlpdump - dev utility tool to convert binary RLP(Recursive Length Prefix) dumps to user friendlier representation.

### DApps and Smart Contracts
DApps - decentralized applicaiton - can operate atonomously, typically thoruhg the use of smart contracts, that run on a blockchain or other dustributed legder system.

DApps use Smart contracts which are programs that run on the blockchain and execute operations. Multiple smart contracts can run one one DApp but in order to deploy them they need gas - which is the currency that is used for deploying and executing them. 

AN complex smart contract of a DAppp that operats on the Ethereum blockchain may fail to be deployed if it costs too much gas, leading to lower throughput and longer wait times for execution.

Operation:
- Dapps use consesus mechanisms over the network - proof-of-work(POW) and proof-of-stake(POS).
POW - Mining consensus - with computational power
POS - consensus mechanism that supports DApps through validatiors that secure the network by having a stake and a percent ownership over the application.

### Genesis Block

### Clients

- execution client
- consensus client
- validator client


- Consensus clients -  (such as Prysm, Teku, Nimbus, Lighthouse, Lodestar) run Ethereum's proof-of-stake consensus algorithm allowing the network to reach agreement about the head of the Beacon Chain. Consensus clients do not participate in validating/broadcasting transactions or executing state transitions. This is done by execution clients. Consensus clients do not attest to, or propose new blocks. This is done by the validator client which is an optional add-on to the consensus client.

Validator - A node in a proof-of-stake system responsible for storing data, processing transactions, and adding new blocks to the blockchain. To activate validator software, you need to be able to stake 32 ETH. More on staking in Ethereum.


### Hardhat

- Hardhat is a flexible and extensible development environment for Ethereum software. It helps you write, test, debug, and deploy your smart contracts with ease, whether you’re building a simple prototype or a complex production system.

- viem is a TypeScript interface for Ethereum that provides low-level stateless primitives for interacting with Ethereum. viem is focused on developer experience, stability, bundle size, and performance.

- Hardhat Tests:
    - Besides being written in TypeScript, there are two important differences between these tests and the Solidity tests you wrote earlier:
        - TypeScript tests use a test runner from the TypeScript ecosystem. Hardhat works with any test runner. In this case, you’re using the built-in node:test module.
        - While Solidity tests run directly on the EVM, TypeScript tests run on a locally simulated network. Each time a test calls network.connect(), it gets a fresh blockchain state, and any changes made during the test are discarded at the end. This is useful for integration tests, where you want a more realistic environment with proper blocks and transactions.

- Hardhat Ignition is a declarative system for deploying smart contracts on Ethereum. It enables you to define smart contract instances you want to deploy, and any operation you want to run on them. By taking over the deployment and execution, Hardhat Ignition lets you focus on your project instead of getting caught up in the deployment details.