#!/bin/bash

rm /cartesi-coprocessor/env/eigenlayer/anvil/devnet-operators-ready.flag
rm -rf /cartesi-coprocessor/contracts/out
rm -rf /cartesi-coprocessor/contracts/cache
rm -rf /cartesi-coprocessor/contracts/broadcast

builder-playground &
sleep 20
#timeout 22 bash -c 'until printf "" 2>>/dev/null >>/dev/tcp/$0/$1; do sleep 1; done' 0.0.0.0:8545

if [ -n "$SKIP_DEPLOYMENT" ]; then
    tail -f /dev/null
fi

source /cartesi-coprocessor/deploy-all-builder-playground.sh

cast send \
    --rpc-url http://0.0.0.0:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --value 30ether 0x02C9ca5313A6E826DC05Bbe098150b3215D5F821

cast send \
    --rpc-url http://0.0.0.0:8545 \
    --private-key 0xc276a0e2815b89e9a3d8b64cb5d745d5b4f6b84531306c97aad82156000a7dd7 \
    0x67d269191c92Caf3cD7723F116c85e6E9bf55933 "mint(address,uint256)" 0x02C9ca5313A6E826DC05Bbe098150b3215D5F821 20    

cast send \
    --rpc-url http://0.0.0.0:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --value 30ether 0x71f897938C155D4569b9f8fbff8fBFC7A89069Fb

cast send \
    --rpc-url http://0.0.0.0:8545 \
    --private-key 0x850affd0f354c8b3b3176ae914dcd90cdb0f2051d1c5e31c9bbf97a732b68a07 \
    0x67d269191c92Caf3cD7723F116c85e6E9bf55933 "mint(address,uint256)" 0x71f897938C155D4569b9f8fbff8fBFC7A89069Fb 20    

cast send \
    --rpc-url http://0.0.0.0:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --value 30ether 0xEc1dc4D2a9459758DCe2bb13096F303a8FAF4c92

cast send \
    --rpc-url http://0.0.0.0:8545 \
    --private-key 0xa38181ab9321e4bfdfe8dae9f99b05529483bdf0254bd5bcbcc51232f26b8c36 \
    0x67d269191c92Caf3cD7723F116c85e6E9bf55933 "mint(address,uint256)" 0xEc1dc4D2a9459758DCe2bb13096F303a8FAF4c92 20    

rm -f /root/.eigenlayer/operator_keys/foo.ecdsa.key.json
echo "abcd" | /usr/local/bin/eigenlayer-cli keys import -i -k ecdsa foo  0xc276a0e2815b89e9a3d8b64cb5d745d5b4f6b84531306c97aad82156000a7dd7 2>&1 | tee /import.log
echo "abcd" | /usr/local/bin/eigenlayer-cli operator register /cartesi-coprocessor/env/eigenlayer/anvil/operator-builder-playground.yaml 2>&1 | tee /register.log

STRATEGY_MANAGER=$(jq -r .strategyManager < /cartesi-coprocessor/contracts/script/input/deployment_parameters_devnet.json)
STRATEGY_ADDRESS=$(jq -r .addresses.erc20MockStrategy < /cartesi-coprocessor/contracts/script/output/coprocessor_deployment_output_devnet.json )
STRATEGY_UNDERLYING=$(cast call --rpc-url http://0.0.0.0:8545 $STRATEGY_ADDRESS "underlyingToken()(address)")

cast send --rpc-url http://0.0.0.0:8545 --private-key 0xc276a0e2815b89e9a3d8b64cb5d745d5b4f6b84531306c97aad82156000a7dd7 $STRATEGY_UNDERLYING "approve(address,uint256)" $STRATEGY_MANAGER 10
cast send --rpc-url http://0.0.0.0:8545 --private-key 0xc276a0e2815b89e9a3d8b64cb5d745d5b4f6b84531306c97aad82156000a7dd7 $STRATEGY_MANAGER "depositIntoStrategy(address,address,uint256)" $STRATEGY_ADDRESS $STRATEGY_UNDERLYING 10

sleep 5
rbuilder run /usr/local/etc/rbuilder-config.yaml > /root/.playground/devnet/logs/rbuilder.log &
echo "started rbuilder - rpc server is listening on :8645"

touch /cartesi-coprocessor/env/eigenlayer/anvil/devnet-operators-ready.flag

tail -f /dev/null