// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/console.sol";

import "../src/CoprocessorCaller.sol";

contract CoprocessorDeployer is Script {
    function run() external {
        string memory coprocessorDeployment = vm.readFile("./script/output/coprocessor_deployment_output_devnet.json");
        address coprocessorAddress = stdJson.readAddress(coprocessorDeployment, ".addresses.coprocessor");
    
        bytes32 machineHash = vm.parseBytes32("6fd2bea72415320a1a26e7466b9bac89ced277b4a59f6f02dd5799bed7e9a738");

        vm.startBroadcast();
        
        CoprocessorCaller caller1 = new CoprocessorCaller(coprocessorAddress, machineHash);
        CoprocessorCaller caller2 = new CoprocessorCaller(coprocessorAddress, machineHash);
        CoprocessorCaller caller3 = new CoprocessorCaller(coprocessorAddress, machineHash);

        vm.stopBroadcast();

        string memory parent_object = "parent object";
        string memory addresses = "addresses";
        vm.serializeAddress(addresses, "caller1", address(caller1));
        vm.serializeAddress(addresses, "caller2", address(caller2));
        string memory addresses_output = vm.serializeAddress(addresses, "caller3", address(caller3));
        string memory finalJson = vm.serializeString(parent_object, addresses, addresses_output);
        vm.writeJson(finalJson, "./script/output/1337/coprocessor_caller_deployment_output_builder_playground.json");
    }
}