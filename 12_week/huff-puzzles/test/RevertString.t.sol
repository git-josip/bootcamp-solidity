// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {console2} from "forge-std/Test.sol";

import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface RevertString {}

contract RevertStringTest is Test {
    RevertString public revertString;

    function setUp() public {
        revertString = RevertString(HuffDeployer.config().deploy("RevertString"));
    }

    function testRevertString() public {
        (bool success, bytes memory revertData) = address(revertString).call("");
        require(!success, "call expected to fail");

        console2.log("XXXXXXXX");
        console2.logBytes(revertData);
        console2.logBytes(bytes("Only Huff"));

        console2.logBytes32(keccak256(bytes("Only Huff")));
        console2.log("AAAAA");
        // console2.logBytes(abi.decode(revertData, (bytes)));
        console2.logBytes32(keccak256(revertData));
        
        assertEq(
            keccak256(bytes("Only Huff")),
            keccak256(revertData),
            // keccak256(abi.decode(revertData, (bytes))), => this was failing. not sure why
            "Expected the call to revert with custom error 'Only Huff' but it didn't "
        );
    }
}
