// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ICoprocessor.sol";
import "./ICoprocessorCallback.sol";

interface ICoprocessorOutputs {
    function Notice(bytes calldata payload) external;
}

contract CoprocessorCaller is ICoprocessorCallback {
    event ResultReceived(bytes output);

    ICoprocessor public coprocessor;
    bytes32 public machineHash;

    mapping(bytes32 => bool) public expectedOutputs;
    mapping(bytes32 => bool) public receivedOutputs;
    mapping(bytes32 => bool) public usedOutputs;

    constructor(address _coprocessorAddress, bytes32 _machineHash) {
        coprocessor = ICoprocessor(_coprocessorAddress);
        machineHash = _machineHash;
    }

    function expectOutput(bytes calldata input) external {
        bytes32 inputHash = keccak256(input);
        expectedOutputs[inputHash] = true;
        receivedOutputs[inputHash] = false;
        usedOutputs[inputHash] = false;
    }

    function useOutput(bytes calldata input) external {
        bytes32 inputHash = keccak256(input);
        require(expectedOutputs[inputHash] == true, "output is not expected");
        require(receivedOutputs[inputHash] == true, "output is not received");
        usedOutputs[inputHash] = true;
    }

    function coprocessorCallbackOutputsOnly(
        bytes32 _machineHash,
        bytes32 inputHash, 
        bytes[] calldata outputs
        ) external override
    {
        require(msg.sender == address(coprocessor), "unauthorized caller");

        require(_machineHash == machineHash, "machine hash mismatch");

        require(expectedOutputs[inputHash] == true, "output not expected");
        require(receivedOutputs[inputHash] == false, "output already received");

        receivedOutputs[inputHash] = true;
        
        for (uint256 i = 0; i < outputs.length; i++) {
            bytes calldata output = outputs[i];

            require(output.length > 3, "Too short output");
            bytes4 selector = bytes4(output[:4]);
            bytes calldata notice = output[4:];

            require(selector == ICoprocessorOutputs.Notice.selector);
            emit ResultReceived(notice);
        }
    }    
}