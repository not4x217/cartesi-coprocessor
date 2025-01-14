#!/bin/bash

# cd to the directory of this script so that this can be run from anywhere
parent_path=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)
# At this point we are in tests/anvil
cd "$parent_path"

cd contracts/lib/eigenlayer-middleware/lib/eigenlayer-contracts
CHAIN_ID=$(cast chain-id)

# deployment overwrites this file, so we save it as backup, because we want that output in our local files, and not in the eigenlayer-contracts submodule files
#mv script/output/devnet/M2_from_scratch_deployment_data.json script/output/devnet/M2_from_scratch_deployment_data.json.bak || true
# M2_Deploy_From_Scratch.s.sol prepends "script/testing/" to the configFile passed as input (M2_deploy_from_scratch.anvil.config.json)
forge script script/deploy/local/Deploy_From_Scratch.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --sig "run(string memory configFile)" -- local/deploy_from_scratch.anvil.config.json
mv script/output/devnet/local_from_scratch_deployment_data.json ../../../../script/output/31337/eigenlayer_deployment_output.json
#mv script/output/devnet/M2_from_scratch_deployment_data.json.bak script/output/devnet/M2_from_scratch_deployment_data.json
