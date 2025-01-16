#!/bin/bash
parent_path=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)

RPC_URL=http://0.0.0.0:8545
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Deploy eigenlayer contracts
cd "$parent_path"
cd contracts/lib/eigenlayer-middleware/lib/eigenlayer-contracts/
CHAIN_ID=$(cast chain-id)
forge script script/deploy/local/Deploy_From_Scratch.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "run(string memory configFile)" -- local/deploy_from_scratch.anvil.config.json 
mv script/output/devnet/local_from_scratch_deployment_data.json ../../../../script/output/1337/eigenlayer_deployment_output_builder_playground.json

# Deploy coprocessor AVS contracts
cd "$parent_path"
cd contracts/
forge script script/CoprocessorDeployerDevnet.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -v